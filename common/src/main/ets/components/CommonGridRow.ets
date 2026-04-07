import { BreakpointConstants } from '../constants/BreakpointConstants'
import { DataSource } from '../model/LazyDataSources'
import { paintByPoint } from '../utils/LayoutTool'

/**
 * 通用可滑动网格列表组件（基于 GridRow/GridCol 栅格响应式布局）
 * 支持滑动滚动、普通数组/懒加载数据源，通过 GridCol 响应式 span 实现多端适配
 * @param data 普通数据源数组（非懒加载场景使用）
 * @param dataSource 懒加载数据源（isLazy 为 true 时生效，支持 LazyForEach）
 * @param isLazy 是否启用懒加载（true：LazyForEach，false：普通 ForEach）
 * @param renderCardItem 自定义 Item 渲染构建器（外部传入自定义 UI 结构）
 * @param columnGap 列间距（可选，默认根据断点自动设置）
 * @param rowGap 行间距（可选，默认根据断点自动设置）
 * @description
* 1. 滑动特性：ScrollView 容器支持垂直滑动；
 * 2. 栅格响应式：通过 GridCol span 对象配置多断点列数，无需监听 breakPoint；
 * 3. 灵活渲染：外部通过 @BuilderParam 传入自定义 Item UI；
 * 4. 性能优化：支持懒加载模式，大数据量场景更流畅
 */
@Component
export struct CommonGridRow {
  @Consume('pathStack') pathStack: NavPathStack;
  @Prop data: object[];
  dataSource: DataSource = new DataSource();
  @Prop isLazy: boolean;
  @BuilderParam renderCardItem: (item: ESObject) => void = this.defaultBuilder
  @Prop columnGap: number = 10
  @Prop rowGap: number = 10

  @Builder
  defaultBuilder() {

  }

  build() {
    Scroll() {
      GridRow({
        columns: 12,
        gutter: { x: this.getColumnGap(), y: this.getRowGap() }
      }) {
        if (this.isLazy) {
          LazyForEach(this.dataSource as DataSource, (item: ESObject) => {
            GridCol({
              span: { sm: 12, md: 6, lg: 4, xl: 3 }
            }) {
              this.renderCardItem(item);
            }
          },
            (item: ESObject) => item.id.toString()
          );
        } else {
          ForEach(
            this.data as ESObject[], (item: ESObject) => {
            GridCol({
              span: { sm: 12, md: 6, lg: 4, xl: 3 }
            }) {
              this.renderCardItem(item);
            }
          }
          );
        }
      }
    }
    .scrollBar(BarState.Off)
    .padding({
      left: paintByPoint(12, BreakpointConstants.BREAKPOINT_MD),
      right: paintByPoint(12, BreakpointConstants.BREAKPOINT_MD),
      top: paintByPoint(8, BreakpointConstants.BREAKPOINT_MD),
      bottom: paintByPoint(16, BreakpointConstants.BREAKPOINT_MD)
    })
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
  }

  private getColumnGap(): number {
    return this.columnGap ?? 10;
  }

  private getRowGap(): number {
    return this.rowGap ?? 10;
  }
}
