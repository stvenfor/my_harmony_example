import { LearnHarmonyEntity } from '../model/LearnHarmonyEntity';
import { fetchHarmonyIndexJson } from '../api/SampleApi';

/**
 * 列表页 ViewModel：错误与数据；加载态由 SampleApi → httpGet(showLoading) 全局遮罩承担。
 */
@Observed
export class LearnHarmonyEntityVM {
  error: string = '';
  data: LearnHarmonyEntity | null = null;

  async loadData(): Promise<void> {
    this.error = '';
    this.data = null;
    const result = await fetchHarmonyIndexJson();
    if (result.code === 0) {
      this.data = result.data ?? null;
      this.error = this.data ? '' : '暂无数据';
    } else {
      this.error = result.message.length > 0 ? result.message : '请求失败';
    }
  }
}
