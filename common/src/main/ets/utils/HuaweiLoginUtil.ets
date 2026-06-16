import { authentication, loginComponentManager } from '@kit.AccountKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common, Want } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  HuaweiAnonymousPhoneResult,
  HuaweiIdCredentialPayload
} from '../../../../../../../../work/project/Dubbing/common/src/main/ets/model/HuaweiKitModel'

/** 华为账号一键登录 AccountKit 封装（不含后端 user/huaweiMobileLogin） */
export class HuaweiLoginUtil {
  /** 未同意华为账号认证协议 */
  static readonly ERROR_AGREEMENT_NOT_ACCEPTED: number = 1005300001
  /** 华为账号未登录 */
  static readonly ERROR_ACCOUNT_NOT_LOGGED_IN: number = 1001502001
  /** 网络异常 */
  static readonly ERROR_NETWORK: number = 1001502005

  static readonly SETTINGS_BUNDLE: string = 'com.huawei.hmos.settings'
  static readonly SETTINGS_ABILITY: string = 'com.huawei.hmos.settings.MainAbility'
  static readonly SETTINGS_URI_ACCOUNTS: string = 'users_accounts'

  /** 打开系统「设置 - 华为账号」 */
  static openHuaweiAccountSettings(context: common.UIAbilityContext): void {
    const want: Want = {
      bundleName: HuaweiLoginUtil.SETTINGS_BUNDLE,
      abilityName: HuaweiLoginUtil.SETTINGS_ABILITY,
      uri: HuaweiLoginUtil.SETTINGS_URI_ACCOUNTS
    }
    context.startAbility(want).then((): void => {
      console.info('HuaweiLoginUtil: open account settings ok')
    }).catch((err: BusinessError): void => {
      console.error(`HuaweiLoginUtil: open settings failed code=${err.code} msg=${err.message}`)
    })
  }

  /** 从 LoginWithHuaweiIDButton 回调中抽取字段 */
  static parseCredential(response: loginComponentManager.HuaweiIDCredential): HuaweiIdCredentialPayload {
    const payload: HuaweiIdCredentialPayload = {
      authorizationCode: response.authorizationCode,
      openId: response.openID,
      unionId: response.unionID,
      idToken: response.idToken ?? ''
    }
    return payload
  }

  /** 创建一键登录按钮控制器（默认未勾选协议；协议勾选/弹窗逻辑由页面自行处理） */
  static createLoginButtonController(
    onLogin: (error: BusinessError | null, credential: HuaweiIdCredentialPayload | null) => void
  ): loginComponentManager.LoginWithHuaweiIDButtonController {
    return new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError,
        response: loginComponentManager.HuaweiIDCredential) => {
        if (error) {
          onLogin(error, null)
          return
        }
        onLogin(null, HuaweiLoginUtil.parseCredential(response))
      })
  }

  static setAgreementAccepted(
    controller: loginComponentManager.LoginWithHuaweiIDButtonController,
    accepted: boolean
  ): void {
    controller.setAgreementStatus(
      accepted ? loginComponentManager.AgreementStatus.ACCEPTED :
        loginComponentManager.AgreementStatus.NOT_ACCEPTED
    )
  }

  /**
   * 预取匿名手机号（需已申请 quickLoginMobilePhone 权限 scope: quickLoginAnonymousPhone）
   * 失败时 resolve 空字符串，不抛错。
   */
  static requestQuickLoginAnonymousPhone(): Promise<HuaweiAnonymousPhoneResult | null> {
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest()
    authRequest.scopes = ['quickLoginAnonymousPhone']
    authRequest.state = util.generateRandomUUID()
    authRequest.forceAuthorization = false
    const controller = new authentication.AuthenticationController()
    return new Promise((resolve: (value: HuaweiAnonymousPhoneResult | null) => void) => {
      controller.executeRequest(authRequest)
        .then((response: authentication.AuthorizationWithHuaweiIDResponse): void => {
          const anonymousPhone = `${response.data?.extraInfo?.quickLoginAnonymousPhone ?? ''}`
          if (anonymousPhone.length === 0) {
            resolve(null)
            return
          }
          const result: HuaweiAnonymousPhoneResult = {
            unionId: `${response.data?.unionID ?? ''}`,
            openId: `${response.data?.openID ?? ''}`,
            anonymousPhone: anonymousPhone
          }
          resolve(result)
        })
        .catch((): void => {
          resolve(null)
        })
    })
  }

  /** 统一处理 AccountKit 错误码（Toast；未登录时可选跳转设置） */
  static handleLoginError(
    error: BusinessError,
    context?: common.UIAbilityContext,
    openSettingsWhenNotLoggedIn: boolean = true
  ): void {
    hilog.error(0x0000, 'HuaweiLoginUtil', 'login failed code=%{public}d msg=%{public}s',
      error.code, error.message)
    let message = error.message
    switch (error.code) {
      case HuaweiLoginUtil.ERROR_AGREEMENT_NOT_ACCEPTED:
        message = '请阅读并同意华为账号用户认证协议!'
        break
      case HuaweiLoginUtil.ERROR_ACCOUNT_NOT_LOGGED_IN:
        message = '请先登录华为账号！'
        break
      case HuaweiLoginUtil.ERROR_NETWORK:
        message = '网络异常，请检查网络！'
        break
      default:
        break
    }
    promptAction.showToast({
      message: message,
      duration: 3000,
      alignment: Alignment.Center
    })
    if (error.code === HuaweiLoginUtil.ERROR_ACCOUNT_NOT_LOGGED_IN &&
      openSettingsWhenNotLoggedIn && context) {
      setTimeout((): void => {
        HuaweiLoginUtil.openHuaweiAccountSettings(context)
      }, 2000)
    }
  }
}
