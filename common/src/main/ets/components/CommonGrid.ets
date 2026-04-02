import { BreakpointConstants } from '../constants/BreakpointConstants'
import { DataSource } from '../model/LazyDataSources'
import { paintByPoint } from '../utils/LayoutTool'

/**
 * 通用可滑动网格列表组件（适配多类型数据与自定义UI）
 * 支持滑动滚动、普通数组/懒加载数据源，按设备断点动态调整网格列数，支持外部自定义Item渲染逻辑
 * @param data 普通数据源数组（非懒加载场景使用）
 * @param dataSource 懒加载数据源（isLazy为true时生效，支持LazyForEach，优化滑动性能）
 * @param isLazy 是否启用懒加载（true：LazyForEach懒加载，false：普通ForEach，适配滑动场景大数据量）
 * @param renderCardItem 自定义Item渲染构建器（可选，默认空实现，外部传入自定义UI结构）
 * @description
* 1. 滑动特性：支持垂直滑动滚动，适配列表数据超出屏幕场景；
 * 2. 断点适配：xl大屏4列/非xl屏2列，列间距随断点自动调整；
 * 3. 灵活渲染：外部通过@BuilderParam传入自定义Item UI，
 */
@Component
export struct CommonGrid {
  @Consume('pathStack') pathStack: NavPathStack;
  @Prop data: object[]; // 兼容普通数组
  dataSource: DataSource = new DataSource();
  @Prop isLazy: boolean; // 是否懒加载
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD;
  @BuilderParam renderCardItem: (item: ESObject) => void = this.defaultBuilder
  // grid的列数
  @Prop gridColumn: number = 2
  @Prop showXianMian: boolean = false // 是否显示限免图标

  @Builder
  defaultBuilder() {

  }

  /**
   * 获取Grid列数（根据断点适配）
   */

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
    // Grid布局配置
    .scrollBar(BarState.Off)
    .columnsTemplate(`repeat(${this.gridColumn}, 1fr)`) // 动态列数
    .columnsGap(this.breakPoint == BreakpointConstants.BREAKPOINT_MD ? 6 : 16)
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
}

