/**
 * 公共 Query 时间戳：客户端秒级时间 + 与服务端对齐的偏移量。
 *
 * 写入偏移：在拿到服务端时间后计算 diffSeconds = serverSec - clientSec，
 * 使用 preferences（store 名 APP_SETTINGS_STORE）put(KEY_SERVER_TIME_OFFSET, diffSeconds) 并 flush。
 * 读取失败时降级为仅本地时间戳，避免请求完全失败。
 */
import { preferences } from '@kit.ArkData';
import { ConfigParams } from '../constants/ConfigParams';

/** 与 features/home HttpHeaderUtil 使用的 preferences 库名一致，便于共享 kServerTimeOffsetSeconds */
const APP_SETTINGS_STORE: string = 'app_settings'

/**
 * preferences 键：服务端与本地时间的差值（秒），可为负。
 * 未设置时 get 默认 0，即 timestamp 等于本地 Unix 秒。
 */
export const KEY_SERVER_TIME_OFFSET: string = 'kServerTimeOffsetSeconds'

/**
 * 构造带校准时间戳的公共 query（当前仅写入 timestamp）。
 * 任意依赖 @ohos/common 的模块均可调用，无需再引用 home 私有工具类。
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
