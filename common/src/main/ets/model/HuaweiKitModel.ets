/** 华为账号一键登录 SDK 回传凭证（业务层再换 token / 调后端） */
export interface HuaweiIdCredentialPayload {
  authorizationCode: string
  openId: string
  unionId: string
  idToken: string
}

/** 预取匿名手机号结果 */
export interface HuaweiAnonymousPhoneResult {
  unionId: string
  openId: string
  anonymousPhone: string
}

/** 华为 IAP 支付请求 */
export interface HuaweiIapPayRequest {
  productId: string
  /** 传给 IAP developerPayload，一般为业务 order_id */
  orderId: string
}

/** IAP 解析后的购买凭据 */
export interface HuaweiIapPurchasePayload {
  productType: number
  purchaseOrderId: string
  purchaseToken: string
}

/** IAP 支付过程回调（业务注入验单、待支付快照等） */
export interface HuaweiIapPayCallbacks {
  /** 服务端验单，返回 true 表示支付成功 */
  onVerifyOrder: (orderId: string) => Promise<boolean>
  onSuccess?: (orderId: string, productId: string) => void
  onCancel?: (orderId: string, productId: string) => void
  onFailure?: (message: string) => void
  /** 华为账号未登录（queryEnvironment / IAP 环境失败码） */
  onAccountNotLoggedIn?: () => void
  /** 用户取消或异常时的待恢复订单（如会员页横幅） */
  onPendingOrder?: (orderId: string, productId: string) => void
}

/** IAP 可选 UI 行为 */
export interface HuaweiIapPayOptions {
  showToast?: (message: string) => void
}
