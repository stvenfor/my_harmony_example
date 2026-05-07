/**
 * 弹出框队列管理器（页面级 / 应用级 + 优先级）
 *
 * 设计背景（与工程内 StarReviewDialog、CustomDialogController 一致）：
 * - HarmonyOS 的 CustomDialog 必须在组件侧持有 CustomDialogController 才能稳定打开/关闭；
 *   本管理器 **不替你 new 弹窗**，只负责「同一作用域内同时多条展示需求时，按优先级串行调度」。
 * - 业务在 `QueuedPopupTask.present` 里打开自己的弹窗，在关闭链路里 **必须** 调用传入的 `finish()`，
 *   否则该作用域队列会卡住，后续任务永远不会执行。
 *
 * 作用域（scope）：
 * - `POPUP_SCOPE_APP`：全应用共享一条队列，适合全局营销、升级提示等（需在根页面长驻一段逻辑来消费 present）。
 * - `popupScopeForPage('VipCenter')` 等：仅该页面关心的队列；页面 `aboutToDisappear` 时建议 `clearPending` 避免泄漏。
 *
 * 优先级：使用 {@link PopupQueuePriority} 枚举；**不同枚举档位**按声明的档位高低排序（高者先展示）；
 * **同一枚举值**视为同级，按入队顺序 **FIFO** 排队。
 */

/** 全应用共用的队列键，任意页面只要传入同一常量即共享一条队列 */
export const POPUP_SCOPE_APP: string = '__popup_scope_app__'

/**
 * 生成页面级作用域键，避免与业务 taskId 冲突。
 * @param pageKey 建议传路由名、页面类名等稳定字符串
 */
export function popupScopeForPage(pageKey: string): string {
  return `__popup_scope_page__:${pageKey}`
}

/**
 * 弹窗优先级枚举：数值仅用于队列内比较，越大越优先。
 * 扩展时：在末尾追加更大档位即可；勿随意改动已有常量的数值，以免与已上线排队语义不一致。
 */
export enum PopupQueuePriority {
  /** 后台静默、弱引导等 */
  LOW = 0,
  NORMAL = 1,
  /** 会员、支付、运营强提示等 */
  HIGH = 2,
  /** 安全、协议强制确认等 */
  CRITICAL = 3
}

/**
 * 队列中的一条弹窗任务。
 * - `taskId`：同一 scope 下重复 enqueue 相同 taskId 时，会 **先移除旧 pending 再插入新任务**（便于「刷新同一条」）。
 * - `present`：轮到本任务时由管理器调用；请在弹窗 **完全关闭** 后调用 `finish()`（含动画结束、蒙层点击后）。
 */
export interface QueuedPopupTask {
  taskId: string
  /** 与 {@link PopupQueuePriority} 比较：不同档位先高后低；同档位严格 FIFO */
  priority: PopupQueuePriority
  /**
   * 打开弹窗：实现里应调用 `this.xxxDialogController.open()` 或 SmartDialog.show 等。
   * @param finish 必须在弹窗关闭时调用一次；管理器会包装为「仅生效一次」防止重复。
   */
  present: (finish: () => void) => void
}

interface ScopeState {
  pending: QueuedPopupTask[]
  /** 当前是否已把一条任务交给 present、且尚未 finish */
  presenting: boolean
}

/**
 * 静态管理器：按 scope 隔离队列，同一 scope 任意时刻最多「展示逻辑上」一条（串行）。
 */
export class PopupDialogQueueManager {
  private static readonly scopeMap: Map<string, ScopeState> = new Map()

  private static getOrCreateState(scope: string): ScopeState {
    let s = PopupDialogQueueManager.scopeMap.get(scope)
    if (s === undefined) {
      s = { pending: [], presenting: false }
      PopupDialogQueueManager.scopeMap.set(scope, s)
    }
    return s
  }

  /**
   * 插入 pending：先跳过所有 **严格大于** 当前 priority 的枚举档位（先展示高档位）；
   * 再跳过末尾所有 **等于** 当前 priority 的项，使新任务排在同档 **最后**（同档 FIFO）。
   */
  private static insertByPriorityFifo(list: QueuedPopupTask[], task: QueuedPopupTask): void {
    let i = 0
    while (i < list.length && list[i].priority > task.priority) {
      i++
    }
    while (i < list.length && list[i].priority === task.priority) {
      i++
    }
    list.splice(i, 0, task)
  }

  private static removePendingByTaskId(list: QueuedPopupTask[], taskId: string): void {
    for (let idx = list.length - 1; idx >= 0; idx--) {
      if (list[idx].taskId === taskId) {
        list.splice(idx, 1)
      }
    }
  }

  /**
   * 入队；若当前 scope 没有在展示，会立即触发队首任务的 present。
   * @returns 当前 pending 条数（含可能刚被调度的一条）
   */
  static enqueue(scope: string, task: QueuedPopupTask): number {
    const state = PopupDialogQueueManager.getOrCreateState(scope)
    PopupDialogQueueManager.removePendingByTaskId(state.pending, task.taskId)
    PopupDialogQueueManager.insertByPriorityFifo(state.pending, task)
    if (!state.presenting) {
      PopupDialogQueueManager.dispatch(scope)
    }
    return state.pending.length + (state.presenting ? 1 : 0)
  }

  /**
   * 仅移除尚未执行 present 的排队任务；**不会**打断当前正在展示的一条。
   */
  static removePending(scope: string, taskId: string): boolean {
    const state = PopupDialogQueueManager.scopeMap.get(scope)
    if (state === undefined) {
      return false
    }
    const before = state.pending.length
    PopupDialogQueueManager.removePendingByTaskId(state.pending, taskId)
    return state.pending.length < before
  }

  /** 清空某 scope 下所有 **pending**；当前正在展示的一条仍会走到 finish 后再由业务决定是否继续 */
  static clearPending(scope: string): void {
    const state = PopupDialogQueueManager.scopeMap.get(scope)
    if (state !== undefined) {
      state.pending.length = 0
    }
  }

  /** 移除该 scope 的全部状态（pending + presenting 标记）；一般仅测试或账号退出时慎用 */
  static resetScope(scope: string): void {
    PopupDialogQueueManager.scopeMap.delete(scope)
  }

  static getPendingCount(scope: string): number {
    const state = PopupDialogQueueManager.scopeMap.get(scope)
    return state !== undefined ? state.pending.length : 0
  }

  static isPresenting(scope: string): boolean {
    const state = PopupDialogQueueManager.scopeMap.get(scope)
    return state !== undefined && state.presenting
  }

  private static dispatch(scope: string): void {
    const state = PopupDialogQueueManager.scopeMap.get(scope)
    if (state === undefined || state.presenting) {
      return
    }
    const next = state.pending.shift()
    if (next === undefined) {
      return
    }
    state.presenting = true
    let finished = false
    const finish = (): void => {
      if (finished) {
        return
      }
      finished = true
      const st = PopupDialogQueueManager.scopeMap.get(scope)
      if (st !== undefined) {
        st.presenting = false
      }
      PopupDialogQueueManager.dispatch(scope)
    }
    try {
      next.present(finish)
    } catch (e) {
      console.error(`[PopupDialogQueueManager] present 异常 scope=${scope} taskId=${next.taskId}`, e)
      finish()
    }
  }
}

/*
 * =============================================================================
 * 使用示例（页面级 scope；应用级把 queueScope 换成 POPUP_SCOPE_APP 即可）
 * =============================================================================
 * 与 VipCenter.openVipPackageToastDialog 相同：在方法内 new CustomDialogController，
 * builder 里传 onRequestClose: () => { dialogController.close(); ... }，并在最后调用队列的 finish()。
 *
 * private readonly queueScopePage: string = popupScopeForPage('MineVipCenter')
 *
 * // 同时入队两条：HIGH 会先 present，关闭并 finish 后才会轮到 LOW
 * enqueueMarketingAndGuide(): void {
 *   PopupDialogQueueManager.enqueue(this.queueScopePage, {
 *     taskId: 'weak_guide',
 *     priority: PopupQueuePriority.LOW,
 *     present: (finish) => {
 *       const ctl = new CustomDialogController({
 *         builder: SomeGuideDialog({
 *           onRequestClose: () => {
 *             ctl.close()
 *             finish()
 *           }
 *         }),
 *         autoCancel: true,
 *         customStyle: true
 *       })
 *       ctl.open()
 *     }
 *   })
 *   PopupDialogQueueManager.enqueue(this.queueScopePage, {
 *     taskId: 'vip_toast',
 *     priority: PopupQueuePriority.HIGH,
 *     present: (finish) => {
 *       const dialogController = new CustomDialogController({
 *         builder: VipPackageToastDialog({
 *           controller: dialogController,
 *           imageUrl: this.entryToastUrl,
 *           onRequestClose: () => {
 *             dialogController.close()
 *             finish()
 *           }
 *         }),
 *         autoCancel: true,
 *         customStyle: true,
 *         alignment: DialogAlignment.Center,
 *         cancel: () => { finish() }
 *       })
 *       dialogController.open()
 *     }
 *   })
 * }
 *
 * aboutToDisappear(): void {
 *   PopupDialogQueueManager.clearPending(this.queueScopePage)
 * }
 *
 * =============================================================================
 */
