/**
 * PopupDialogQueueManager 功能演示页（开发自测用）
 *
 * 进入方式：任意已注入 NavPathStack 的页面执行
 * `this.pathStack.pushPathByName('PopupDialogQueueDemoPage', null, false)`。
 *
 * 演示点：同 scope 下按 PopupQueuePriority 档位先后展示，同档 FIFO；关窗必须调 finish；
 * 页面级 scope 与 POPUP_SCOPE_APP 隔离；同 taskId 再次入队会替换尚未执行的旧任务。
 */
import {
  POPUP_SCOPE_APP,
  PageHeaderComp,
  PopupDialogQueueManager,
  PopupQueuePriority,
  StringConstants,
  popupScopeForPage
} from '@ohos/common'

/** 演示用简单弹层：标题 + 说明 + 关闭按钮；一律走 onRequestClose，避免 builder 内引用未完成的 controller */
@CustomDialog
struct DemoQueueSimpleDialog {
  /** 框架可能注入；演示页关闭逻辑不依赖此字段 */
  controller?: CustomDialogController
  titleText: string = ''
  bodyText: string = ''
  /** 由外层传入：内先 controller.close() 再通知队列 finish */
  onRequestClose?: () => void

  build() {
    Column() {
      Text(this.titleText)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .width('100%')
      Text(this.bodyText)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
        .width('100%')
      Button('关闭（会调用 finish，下一条才会弹出）')
        .type(ButtonType.Capsule)
        .width('100%')
        .margin({ top: 24 })
        .onClick((): void => {
          if (this.onRequestClose !== undefined) {
            this.onRequestClose()
          } else if (this.controller !== undefined) {
            this.controller.close()
          }
        })
    }
    .padding(24)
    .width('86%')
    .constraintSize({ maxWidth: 360 })
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}

@Component
export struct PopupDialogQueueDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  /** 本页专用队列键，离开页面时 clearPending，避免未展示任务残留 */
  private readonly scopePage: string = popupScopeForPage('PopupDialogQueueDemoPage')

  @State logText: string = '点击下方按钮观察入队顺序与弹窗顺序。\n'
  @State statusLine: string = ''

  private appendLog(line: string): void {
    const prefix: string = `${new Date().toLocaleTimeString()}  `
    this.logText = `${prefix}${line}\n${this.logText}`.slice(0, 4000)
  }

  private refreshStatus(): void {
    const pPending: number = PopupDialogQueueManager.getPendingCount(this.scopePage)
    const pShow: boolean = PopupDialogQueueManager.isPresenting(this.scopePage)
    const aPending: number = PopupDialogQueueManager.getPendingCount(POPUP_SCOPE_APP)
    const aShow: boolean = PopupDialogQueueManager.isPresenting(POPUP_SCOPE_APP)
    this.statusLine =
      `【页面队列】pending=${pPending} 展示中=${pShow}\n【应用队列】pending=${aPending} 展示中=${aShow}`
    this.appendLog(`状态刷新 → 页 pending=${pPending} 页展示=${pShow}；应用 pending=${aPending} 应用展示=${aShow}`)
  }

  private priorityLabel(p: PopupQueuePriority): string {
    switch (p) {
      case PopupQueuePriority.CRITICAL:
        return 'CRITICAL'
      case PopupQueuePriority.HIGH:
        return 'HIGH'
      case PopupQueuePriority.NORMAL:
        return 'NORMAL'
      case PopupQueuePriority.LOW:
        return 'LOW'
      default:
        return 'UNKNOWN'
    }
  }

  private openDemoDialog(
    scope: string,
    taskId: string,
    priority: PopupQueuePriority,
    titleText: string,
    finish: () => void
  ): void {
    const body: string =
      `taskId=${taskId}\npriority=${this.priorityLabel(priority)}\nscope=${scope === POPUP_SCOPE_APP ? 'APP' : 'PAGE'}\n\n先关掉当前窗，队列才会继续。`
    const dialogController: CustomDialogController = new CustomDialogController({
      builder: DemoQueueSimpleDialog({
        titleText: titleText,
        bodyText: body,
        onRequestClose: (): void => {
          dialogController.close()
          finish()
          this.appendLog(`已关闭弹窗并 finish：${taskId}`)
          this.refreshStatus()
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true,
      maskColor: 'rgba(0,0,0,0.55)',
      cancel: (): void => {
        finish()
        this.appendLog(`蒙层取消 finish：${taskId}`)
        this.refreshStatus()
      }
    })
    dialogController.open()
    this.appendLog(`present 已执行并 open：${taskId}（${this.priorityLabel(priority)}）`)
  }

  /** 一次入队多条且档位乱序：应先 HIGH → NORMAL → LOW（不同枚举档位） */
  private enqueueBatchShuffled(): void {
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'demo_low',
      priority: PopupQueuePriority.LOW,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'demo_low', PopupQueuePriority.LOW, 'LOW 档位', finish)
      }
    })
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'demo_high',
      priority: PopupQueuePriority.HIGH,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'demo_high', PopupQueuePriority.HIGH, 'HIGH 档位（应最先出现）', finish)
      }
    })
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'demo_normal',
      priority: PopupQueuePriority.NORMAL,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'demo_normal', PopupQueuePriority.NORMAL, 'NORMAL 档位', finish)
      }
    })
    this.appendLog('已乱序入队 3 条（LOW→HIGH→NORMAL），预期弹出顺序：HIGH → NORMAL → LOW')
    this.refreshStatus()
  }

  /** 连续三条均为 HIGH：应先 A → B → C（同枚举值 FIFO） */
  private enqueueThreeHighFifo(): void {
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'fifo_high_a',
      priority: PopupQueuePriority.HIGH,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'fifo_high_a', PopupQueuePriority.HIGH, 'HIGH #1（先入队）', finish)
      }
    })
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'fifo_high_b',
      priority: PopupQueuePriority.HIGH,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'fifo_high_b', PopupQueuePriority.HIGH, 'HIGH #2', finish)
      }
    })
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'fifo_high_c',
      priority: PopupQueuePriority.HIGH,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'fifo_high_c', PopupQueuePriority.HIGH, 'HIGH #3（最后入队）', finish)
      }
    })
    this.appendLog('已入队 3 条均为 PopupQueuePriority.HIGH，预期顺序：#1 → #2 → #3（同档 FIFO）')
    this.refreshStatus()
  }

  /** 同 taskId 再次入队：替换尚未执行的条目，最终以最后一次枚举档位为准 */
  private enqueueSameIdTwice(): void {
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'same_id_task',
      priority: PopupQueuePriority.LOW,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'same_id_task', PopupQueuePriority.LOW, '同 taskId 第一次 LOW', finish)
      }
    })
    PopupDialogQueueManager.enqueue(this.scopePage, {
      taskId: 'same_id_task',
      priority: PopupQueuePriority.CRITICAL,
      present: (finish: () => void): void => {
        this.openDemoDialog(this.scopePage, 'same_id_task', PopupQueuePriority.CRITICAL, '同 taskId 第二次 CRITICAL', finish)
      }
    })
    this.appendLog('已对同 taskId「same_id_task」入队两次：仅替换「尚未执行」的同名 pending；若第一条已开始展示，第二条会排在后面')
    this.refreshStatus()
  }

  /** 应用级队列：与页面队列独立，适合全局长驻逻辑消费 */
  private enqueueAppHigh(): void {
    PopupDialogQueueManager.enqueue(POPUP_SCOPE_APP, {
      taskId: 'demo_app_marketing',
      priority: PopupQueuePriority.HIGH,
      present: (finish: () => void): void => {
        this.openDemoDialog(POPUP_SCOPE_APP, 'demo_app_marketing', PopupQueuePriority.HIGH, '【应用级队列】HIGH', finish)
      }
    })
    this.appendLog('已向 POPUP_SCOPE_APP 入队一条 HIGH（与页面队列互不抢占，各自串行）')
    this.refreshStatus()
  }

  aboutToAppear(): void {
    this.refreshStatus()
  }

  aboutToDisappear(): void {
    // 仅清空未展示的排队；若用户未关弹窗就返回，由系统销毁弹层，业务上仍应在 finish 里收尾
    PopupDialogQueueManager.clearPending(this.scopePage)
    PopupDialogQueueManager.clearPending(POPUP_SCOPE_APP)
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '弹窗队列演示',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Text(this.statusLine)
          .fontSize(12)
          .fontColor('#0066cc')
          .padding(12)
          .width('100%')
          .backgroundColor('#f0f7ff')

        Scroll() {
          Column({ space: 10 }) {
            Text('说明：不同枚举档位先高后低；同一档位按入队先后 FIFO。同 scope 同时只展示一条。')
              .fontSize(13)
              .fontColor('#666666')
              .width('100%')

            Button('① 乱序入队 3 条（验证档位顺序）')
              .width('100%')
              .onClick((): void => {
                this.enqueueBatchShuffled()
              })

            Button('⑦ 三条均为 HIGH（验证同档 FIFO）')
              .width('100%')
              .onClick((): void => {
                this.enqueueThreeHighFifo()
              })

            Button('② 同 taskId 入队两次（验证替换 pending）')
              .width('100%')
              .onClick((): void => {
                this.enqueueSameIdTwice()
              })

            Button('③ 应用级队列入队（POPUP_SCOPE_APP）')
              .width('100%')
              .onClick((): void => {
                this.enqueueAppHigh()
              })

            Button('④ 刷新状态 / 写日志')
              .width('100%')
              .onClick((): void => {
                this.refreshStatus()
              })

            Button('⑤ 仅清空页面 pending（不打断当前窗）')
              .width('100%')
              .onClick((): void => {
                PopupDialogQueueManager.clearPending(this.scopePage)
                this.appendLog('已 clearPending(页面 scope)')
                this.refreshStatus()
              })

            Button('⑥ 仅清空应用 pending')
              .width('100%')
              .onClick((): void => {
                PopupDialogQueueManager.clearPending(POPUP_SCOPE_APP)
                this.appendLog('已 clearPending(POPUP_SCOPE_APP)')
                this.refreshStatus()
              })

            Text('日志（新在上）')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
              .width('100%')
            Text(this.logText)
              .fontSize(11)
              .fontColor('#444444')
              .width('100%')
              .padding(8)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
          }
          .padding(16)
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.topArea, bottom: this.bottomArea })
      .backgroundColor('#ffffff')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
