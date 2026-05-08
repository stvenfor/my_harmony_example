/**
 * 通用键值参数（请求头、query 等）。
 * 值为 string / number 等 JSON 可序列化类型；与 ArkTS 严格模式并存时使用需自行收窄类型。
 */
export interface ConfigParams {
  [key: string]: any
}