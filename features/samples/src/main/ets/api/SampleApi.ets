import { ApiResult, httpGet } from '@ohos/common';
import { LearnHarmonyEntity } from '../model/LearnHarmonyEntity';

/**
 * 玩 Android 鸿蒙首页聚合接口
 * @param showLoading 是否展示全局 Loading，仅此参数控制，默认 true
 * @see https://www.wanandroid.com/
 */
export async function fetchHarmonyIndexJson(showLoading: boolean = true): Promise<ApiResult<LearnHarmonyEntity>> {
  return httpGet<LearnHarmonyEntity>('/harmony/index/json', undefined, { showLoading });
}
