import { StringConstants } from '@ohos/common'

/** 分栏示例：用项目已有安全区占位，替代官方示例的 cutout 计算 */
export function mcGetTop(): number {
  return 0
}

export function mcGetLeft(): number {
  return 0
}

export function mcGetRight(): number {
  return 0
}

export function mcGetBottom(): number {
  return AppStorage.get<number>(StringConstants.BOTTOM_AREA) ?? 0
}
