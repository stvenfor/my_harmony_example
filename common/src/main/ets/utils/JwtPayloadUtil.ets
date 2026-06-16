import { util } from '@kit.ArkTS'

/** 解析华为 IAP JWS 中 payload 段（Base64Url → JSON 字符串） */
export class JwtPayloadUtil {
  private static centerLineRegex: RegExp = new RegExp('-', 'g')
  private static underLineRegex: RegExp = new RegExp('_', 'g')
  private static textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
  private static base64: util.Base64Helper = new util.Base64Helper()
  private static readonly BASE64_PAD_MOD: number = 4
  private static readonly BASE64_PAD_INVALID: number = 1

  private static base64Decode(input: string): string {
    return JwtPayloadUtil.textDecoder.decodeWithStream(JwtPayloadUtil.base64.decodeSync(input))
  }

  private static base64UrlDecode(input: string): string {
    let normalized = input.replace(JwtPayloadUtil.centerLineRegex, '+').replace(JwtPayloadUtil.underLineRegex, '/')
    const pad = normalized.length % JwtPayloadUtil.BASE64_PAD_MOD
    if (pad) {
      if (pad === JwtPayloadUtil.BASE64_PAD_INVALID) {
        throw new Error('InvalidLengthError: Input base64url string is the wrong length to determine padding')
      }
      normalized += new Array(5 - pad).join('=')
    }
    return JwtPayloadUtil.base64Decode(normalized)
  }

  static decodeJwtPayload(data: string): string {
    const jwt: string[] = data.split('.')
    if (jwt.length < 3) {
      return ''
    }
    try {
      return JwtPayloadUtil.base64UrlDecode(jwt[1])
    } catch (_e) {
      return ''
    }
  }
}
