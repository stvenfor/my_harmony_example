import { preferences } from '@kit.ArkData';
import { ConfigParams } from '../constants/ConfigParams';

/** 与 HttpHeaderUtil 中 preferences 名称保持一致 */
const APP_SETTINGS_STORE: string = 'app_settings'
/** 服务端与本地时间差（秒），由业务同步写入 */
export const KEY_SERVER_TIME_OFFSET: string = 'kServerTimeOffsetSeconds'

/**
 * 构造带校准时间戳的公共 query 字典（仅含 timestamp 等公共字段）。
 * 供 entry / home 等模块调用，避免对 home 内 HttpHeaderUtil 的类型依赖不完整。
 */
export async function buildCommonQueryMapWithTimestamp(): Promise<ConfigParams> {
  const newParam: ConfigParams = {}
  try {
    const clientTimeStamp: number = Math.floor(Date.now() / 1000)
    const prefs = await preferences.getPreferences(getContext(), APP_SETTINGS_STORE)
    const timeStampDistance: number = await prefs.get(KEY_SERVER_TIME_OFFSET, 0) as number
    newParam['timestamp'] = String(clientTimeStamp + timeStampDistance)
  } catch (err) {
    console.error('buildCommonQueryMapWithTimestamp failed', JSON.stringify(err))
    newParam['timestamp'] = String(Math.floor(Date.now() / 1000))
  }
  return newParam
}
