/** 商品数据（与 H5 product_list.js 结构一致） */
export default interface ProductModel {
  id: number
  name: string
  img: string
  price: number
  sku?: string
}

/** 注入 Web 的 ArkTS 桥接对象 */
export interface ArkTSFunModel {
  jumpOrderConfirm: (detailStr: string) => void
}
