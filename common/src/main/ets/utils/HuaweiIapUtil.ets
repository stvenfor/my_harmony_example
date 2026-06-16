import { common, Want } from '@kit.AbilityKit'
import { iap } from '@kit.IAPKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import {
  HuaweiIapPayCallbacks,
  HuaweiIapPayOptions,
  HuaweiIapPayRequest,
  HuaweiIapPurchasePayload
} from '../../../../../../../../work/project/Dubbing/common/src/main/ets/model/HuaweiKitModel'
import { JwtPayloadUtil } from './JwtPayloadUtil'

interface IapPurchaseDataJson {
  type: number
  jwsPurchaseOrder?: string
  jwsSubscriptionStatus?: string
}

interface IapCreatePurchaseDataJson {
  jwsPurchaseOrder: string
}

/** 华为 IAP 支付 Kit 封装（不含 funds 验单；通过 callbacks 注入业务） */
export class HuaweiIapUtil {
  /** IAP 环境：华为账号未登录 */
  static readonly ENV_ACCOUNT_NOT_LOGGED_IN: number = 1001860050
  /** 用户取消支付 */
  static readonly PAY_USER_CANCELED: number = 1001860000

  private static context: common.UIAbilityContext | null = null

  static bindContext(context: common.UIAbilityContext): void {
    HuaweiIapUtil.context = context
  }

  private static getContextOrThrow(): common.UIAbilityContext {
    if (HuaweiIapUtil.context) {
      return HuaweiIapUtil.context
    }
    return getContext() as common.UIAbilityContext
  }

  private static toast(message: string, options?: HuaweiIapPayOptions): void {
    if (options?.showToast) {
      options.showToast(message)
      return
    }
    promptAction.showToast({ message: message, alignment: Alignment.Center })
  }

  /** 解析 IAP 商品 ID：优先订单 ios_product_id，否则 harmony / ios 回退 */
  static resolveProductId(orderIosProductId: string, fallbackProductId: string): string {
    const fromOrder = `${orderIosProductId ?? ''}`.trim()
    if (fromOrder.length > 0) {
      return fromOrder
    }
    return `${fallbackProductId ?? ''}`.trim()
  }

  /** 查询 IAP 环境；0 表示可用 */
  static async queryEnvironmentStatus(): Promise<number> {
    const ctx = HuaweiIapUtil.getContextOrThrow()
    return new Promise((resolve: (code: number) => void) => {
      iap.queryEnvironmentStatus(ctx).then((): void => {
        resolve(0)
      }).catch((err: BusinessError): void => {
        resolve(err.code)
      })
    })
  }

  static openHuaweiAccountSettings(context?: common.UIAbilityContext): void {
    const ctx = context ?? HuaweiIapUtil.getContextOrThrow()
    const want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility'
    }
    ctx.startAbility(want).catch((): void => {
    })
  }

  /** 清理未完成 consumable 订单（仅 finishPurchase，不验单） */
  static async clearUnfinishedConsumablePurchases(): Promise<void> {
    const ctx = HuaweiIapUtil.getContextOrThrow()
    const param: iap.QueryPurchasesParameter = {
      productType: iap.ProductType.CONSUMABLE,
      queryType: iap.PurchaseQueryType.UNFINISHED
    }
    try {
      const res: iap.QueryPurchaseResult = await iap.queryPurchases(ctx, param)
      const purchaseDataList: string[] = res.purchaseDataList ?? []
      for (let i = 0; i < purchaseDataList.length; i++) {
        const payload = HuaweiIapUtil.parsePurchasePayloadFromData(purchaseDataList[i])
        if (!payload) {
          continue
        }
        await HuaweiIapUtil.finishPurchaseSdk(payload)
      }
    } catch (_e) {
    }
  }

  private static parsePurchasePayloadFromData(purchaseData: string): HuaweiIapPurchasePayload | null {
    const jwsPurchaseOrder = (JSON.parse(purchaseData) as IapPurchaseDataJson)
    if (!jwsPurchaseOrder?.jwsPurchaseOrder) {
      return null
    }
    const purchaseStr = JwtPayloadUtil.decodeJwtPayload(jwsPurchaseOrder.jwsPurchaseOrder)
    if (purchaseStr.length === 0) {
      return null
    }
    const parsed = JSON.parse(purchaseStr) as HuaweiIapPurchasePayload
    return parsed
  }

  private static async finishPurchaseSdk(purchase: HuaweiIapPurchasePayload): Promise<void> {
    const ctx = HuaweiIapUtil.getContextOrThrow()
    const finishPurchaseParam: iap.FinishPurchaseParameter = {
      productType: purchase.productType,
      purchaseToken: purchase.purchaseToken,
      purchaseOrderId: purchase.purchaseOrderId
    }
    await iap.finishPurchase(ctx, finishPurchaseParam).catch((): void => {
    })
  }

  /**
   * 完整 consumable 支付：查环境 → 清未完成单 → queryProducts → createPurchase → 业务验单 → finishPurchase
   */
  static async payConsumable(
    request: HuaweiIapPayRequest,
    callbacks: HuaweiIapPayCallbacks,
    options?: HuaweiIapPayOptions
  ): Promise<void> {
    const envCode = await HuaweiIapUtil.queryEnvironmentStatus()
    if (envCode === HuaweiIapUtil.ENV_ACCOUNT_NOT_LOGGED_IN) {
      if (callbacks.onAccountNotLoggedIn) {
        callbacks.onAccountNotLoggedIn()
      } else {
        HuaweiIapUtil.toast('您的华为账号没有登录，请先登录华为账号', options)
        HuaweiIapUtil.openHuaweiAccountSettings()
      }
      return
    }
    if (envCode !== 0) {
      HuaweiIapUtil.toast('支付异常', options)
      if (callbacks.onFailure) {
        callbacks.onFailure('支付异常')
      }
      return
    }

    if (`${request.productId}`.trim().length === 0) {
      HuaweiIapUtil.toast('商品 ID 为空', options)
      if (callbacks.onFailure) {
        callbacks.onFailure('商品 ID 为空')
      }
      return
    }

    await HuaweiIapUtil.clearUnfinishedConsumablePurchases()

    const ctx = HuaweiIapUtil.getContextOrThrow()
    const queryProductParam: iap.QueryProductsParameter = {
      productType: iap.ProductType.CONSUMABLE,
      productIds: [request.productId]
    }
    try {
      const products = await iap.queryProducts(ctx, queryProductParam)
      if (!products || products.length === 0) {
        HuaweiIapUtil.toast('请确保商户状态正常开通！', options)
        if (callbacks.onFailure) {
          callbacks.onFailure('商品不可用')
        }
        return
      }
      await HuaweiIapUtil.createAndFinishPurchase(products[0].id, products[0].type, request, callbacks, options)
    } catch (err) {
      HuaweiIapUtil.toast('请确保商户状态正常开通！', options)
      if (callbacks.onFailure) {
        callbacks.onFailure('queryProducts 失败')
      }
    }
  }

  private static async createAndFinishPurchase(
    productId: string,
    productType: iap.ProductType,
    request: HuaweiIapPayRequest,
    callbacks: HuaweiIapPayCallbacks,
    options?: HuaweiIapPayOptions
  ): Promise<void> {
    const ctx = HuaweiIapUtil.getContextOrThrow()
    const createPurchaseParam: iap.PurchaseParameter = {
      productId: productId,
      productType: productType,
      developerPayload: request.orderId
    }
    try {
      const result = await iap.createPurchase(ctx, createPurchaseParam)
      const parsedData = JSON.parse(result.purchaseData) as IapCreatePurchaseDataJson
      const purchaseStr = JwtPayloadUtil.decodeJwtPayload(parsedData.jwsPurchaseOrder)
      const purchaseOrderPayload = JSON.parse(purchaseStr) as HuaweiIapPurchasePayload
      await HuaweiIapUtil.verifyAndFinish(purchaseOrderPayload, request.orderId, productId, callbacks, options)
    } catch (err) {
      const e = err as BusinessError
      if (e.code === HuaweiIapUtil.PAY_USER_CANCELED) {
        HuaweiIapUtil.toast('已取消支付', options)
        if (callbacks.onCancel) {
          callbacks.onCancel(request.orderId, productId)
        }
      } else {
        const msg = `支付失败(${e.code})`
        HuaweiIapUtil.toast(msg, options)
        if (callbacks.onFailure) {
          callbacks.onFailure(msg)
        }
      }
      if (callbacks.onPendingOrder && request.orderId.length > 0 && productId.length > 0) {
        callbacks.onPendingOrder(request.orderId, productId)
      }
    }
  }

  private static async verifyAndFinish(
    purchase: HuaweiIapPurchasePayload,
    businessOrderId: string,
    productId: string,
    callbacks: HuaweiIapPayCallbacks,
    options?: HuaweiIapPayOptions
  ): Promise<void> {
    const verified = await callbacks.onVerifyOrder(businessOrderId)
    if (verified) {
      await HuaweiIapUtil.finishPurchaseSdk(purchase)
      HuaweiIapUtil.toast('支付成功', options)
      if (callbacks.onSuccess) {
        callbacks.onSuccess(businessOrderId, productId)
      }
      return
    }
    HuaweiIapUtil.toast('支付失败', options)
    if (callbacks.onFailure) {
      callbacks.onFailure('服务端验单未通过')
    }
    if (callbacks.onPendingOrder) {
      callbacks.onPendingOrder(businessOrderId, productId)
    }
    await HuaweiIapUtil.finishPurchaseSdk(purchase)
  }
}
