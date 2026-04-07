import { BreakpointConstants } from '../constants/BreakpointConstants'
import { DataSource } from '../model/LazyDataSources'
import { paintByPoint } from '../utils/LayoutTool'

/**
 * 通用可滑动网格列表组件（适配多类型数据与自定义 UI）
 * 支持滑动滚动、普通数组/懒加载数据源，按设备断点动态调整网格列数，支持外部自定义 Item 渲染逻辑
 * @param data 普通数据源数组（非懒加载场景使用）
 * @param dataSource 懒加载数据源（isLazy 为 true 时生效，支持 LazyForEach，优化滑动性能）
 * @param isLazy 是否启用懒加载（true：LazyForEach 懒加载，false：普通 ForEach，适配滑动场景大数据量）
 * @param renderCardItem 自定义 Item 渲染构建器（可选，默认空实现，外部传入自定义 UI 结构）
 * @param columnGap 列间距（可选，默认根据断点自动设置）
 * @param rowGap 行间距（可选，默认根据断点自动设置）
 * @description
* 1. 滑动特性：支持垂直滑动滚动，适配列表数据超出屏幕场景；
 * 2. 断点适配：xl 大屏 4 列/非 xl 屏 2 列，列间距随断点自动调整；
 * 3. 灵活渲染：外部通过@BuilderParam 传入自定义 Item UI，
 */
@Component
export struct CommonGrid {
  @Consume('pathStack') pathStack: NavPathStack;
  @Prop data: object[]; // 兼容普通数组
  dataSource: DataSource = new DataSource();
  @Prop isLazy: boolean; // 是否懒加载
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD;
  @BuilderParam renderCardItem: (item: ESObject) => void = this.defaultBuilder
  // grid 的列数
  @Prop gridColumn: number = 2
  @Prop columnGap: number = 10 // 列间距（可选，不传则根据断点自动计算）
  @Prop rowGap: number = 10 // 行间距（可选，不传则根据断点自动计算）

  @Builder
  defaultBuilder() {

  }

  build() {
    Grid() {
      // 区分普通循环和懒加载循环
      if (this.isLazy) {
        LazyForEach(this.dataSource as DataSource, (item: ESObject) => {
          GridItem() {
            this.renderCardItem(item);
          }
        },
          (item: ESObject) => item.id.toString()
        );
      } else {
        ForEach(
          this.data as ESObject[], (item: ESObject) => {
          GridItem() {
            this.renderCardItem(item);
          }
        }
        );
      }
    }
    // Grid 布局配置
    .scrollBar(BarState.Off)
    .columnsTemplate(`repeat(${this.gridColumn}, 1fr)`) // 动态列数
    .columnsGap(this.getColumnGap())
    .rowsGap(this.getRowGap())
    .padding({
      left: this.breakPoint === 'xl'
        ? paintByPoint(64, this.breakPoint)
        : paintByPoint(12, this.breakPoint),
      right: this.breakPoint === 'xl'
        ? paintByPoint(64, this.breakPoint)
        : paintByPoint(12, this.breakPoint),
      top: paintByPoint(8, this.breakPoint), // 顶部轻微内边距，优化视觉
      bottom: paintByPoint(16, this.breakPoint) // 底部内边距，避免贴底
    })
    .width('100%')
  }

  /**
   * 获取 Grid 列数（根据断点适配）
   */
  private getColumnGap(): number {
    return this.columnGap ?? (this.breakPoint == BreakpointConstants.BREAKPOINT_MD ? 6 : 16)
  }

  private getRowGap(): number {
    return this.rowGap ?? (this.breakPoint == BreakpointConstants.BREAKPOINT_MD ? 6 : 16)
  }
}
