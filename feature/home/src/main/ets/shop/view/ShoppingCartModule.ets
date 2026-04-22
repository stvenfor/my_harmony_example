import {
  DataSource,
  DataSourceStyleAStyleA,
  DataSourceStyleBStyleB,
  DataSourceStyleCStyleC
} from '../viewmodel/ShoppingCartModuleData';

@Component
struct ShopPromotionInfo {
  @Prop promotion: string = "满199减30";
  @Prop detailText: string = "再购39元享包邮";

  build() {
    Row() {
      Row() {
        Text(this.promotion)
          .fontSize(10)
          .fontColor($r('app.color.promotion_primary_JD_ShoppingCart'))
        Image($r('app.media.ic_right_arrow_filled'))
          .width(8)
          .height(8)
          .margin({ left: 2 })
          .fillColor($r('app.color.promotion_primary_JD_ShoppingCart'))
      }
      .backgroundColor($r('app.color.promotion_background_JD_ShoppingCart'))
      .padding({
        left: 8,
        right: 4,
        top: 4,
        bottom: 4
      })
      .borderRadius(8)

      Text(this.detailText)
        .fontSize(11)
        .fontColor($r('app.color.font_secondary_JD_ShoppingCart'))
        .margin({ left: 4 })
      Blank()
      Row() {
        Text("再逛逛")
          .fontSize(10)
          .fontColor($r('app.color.font_primary_JD_ShoppingCart'))
          .margin({ left: 8 })
        Image($r('app.media.ic_right_arrow_filled'))
          .width(8)
          .height(8)
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .height(24)
    .margin({ bottom: 8 })
  }
}

@Component
struct ProductItem {
  @ObjectLink product: DataSourceStyleBStyleB;
  @Prop shopId: string;
  onProductSelect: (shopId: string, productId: string, selected: boolean) => void = () => {
  };
  onQuantityChange: (shopId: string, productId: string, quantity: number) => void = () => {
  };

  build() {
    Row() {
      Row() {
        Checkbox()
          .select(this.product.isSelected)
          .margin({ right: 8 })
          .onChange((isChecked: boolean) => {
            this.onProductSelect(this.shopId, this.product.id, isChecked);
          })
          .width(16)
          .height(16)
        Image(this.product.image)
          .width(90)
          .height(90)
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
          .margin({ right: 8 })
      }

      Column() {
        Row() {
          Text(this.product.name)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')

        Row() {
          Row() {
            Text(this.product.specs)
              .fontSize(11)
              .fontColor($r('app.color.font_secondary_JD_ShoppingCart'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Image($r('app.media.ic_right_arrow_filled'))
              .fillColor($r('app.color.font_secondary_JD_ShoppingCart'))
              .width(8)
              .height(8)
              .rotate({ angle: 90 })
              .margin({ left: 2 })
          }
          .justifyContent(FlexAlign.Start)
          .padding({
            left: 8,
            right: 12,
            top: 4,
            bottom: 4
          })
          .backgroundColor($r('app.color.background_secondary_JD_ShoppingCart'))
          .borderRadius(8)
          .margin({ top: 8, bottom: 6 })
        }
        .width('100%')

        if (this.product.hasPromotion) {
          Row() {
            Text(this.product.promotionInfo)
              .fontSize(10)
              .fontColor($r('app.color.promotion_primary_JD_ShoppingCart'))
            Text(this.product.warranty)
              .fontSize(10)
              .fontColor($r('app.color.warranty_primary_JD_ShoppingCart'))
              .margin({ left: 8 })
          }
          .width('100%')
        } else {
          Text(this.product.warranty)
            .fontSize(10)
            .fontColor($r('app.color.warranty_primary_JD_ShoppingCart'))
            .margin({ top: 6 })
            .width('100%')
        }
        if (this.product.nationSubsidy) {
          Row() {
            Text("国补领后约")
              .fontSize(12)
              .fontColor($r('app.color.subsidy_primary_JD_ShoppingCart'))
            Text(`¥${this.product.nationSubsidyAmount.toFixed(2)}`)
              .fontSize(12)
              .fontColor($r('app.color.subsidy_primary_JD_ShoppingCart'))
              .fontWeight(FontWeight.Bold)
            Image($r('app.media.ic_right_arrow_filled'))
              .width(8)
              .height(8)
              .margin({ left: 4 })
          }
          .margin({ top: 6 })
          .width('100%')
        }
        Row() {
          Row() {
            Text(`¥${this.product.price.toFixed(0)}`)
              .fontSize(18)
              .fontColor($r('app.color.promotion_primary_JD_ShoppingCart'))
              .fontWeight(FontWeight.Bold)
            Text("到手价")
              .fontSize(11)
              .fontColor($r('app.color.promotion_primary_JD_ShoppingCart'))
              .margin({ left: 2, bottom: 2 })
              .alignSelf(ItemAlign.End)
            if (this.product.originalPrice > this.product.price) {
              Text(`¥${this.product.originalPrice.toFixed(0)}`)
                .fontSize(10)
                .fontColor($r('app.color.font_tertiary_JD_ShoppingCart'))
                .margin({ left: 6, bottom: 2 })
                .alignSelf(ItemAlign.End)
            }
          }

          Row() {
            Text("-")
              .fontColor($r('app.color.font_primary_JD_ShoppingCart'))
              .fontWeight(FontWeight.Normal)
              .fontSize(18)
              .onClick(() => {
                if (this.product.quantity > 1) {
                  this.onQuantityChange(this.shopId, this.product.id, this.product.quantity - 1);
                }
              })
            Text(this.product.quantity.toString())
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .borderRadius(8)
              .backgroundColor($r('app.color.quantity_background_JD_ShoppingCart'))
              .padding({
                left: 12,
                right: 12,
                top: 4,
                bottom: 4
              })
              .margin({ left: 3, right: 3 })
            Text("+")
              .fontColor($r('app.color.font_primary_JD_ShoppingCart'))
              .fontWeight(FontWeight.Normal)
              .fontSize(18)
              .onClick(() => {
                this.onQuantityChange(this.shopId, this.product.id, this.product.quantity + 1);
              })
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 6 })
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding({ top: 6, bottom: 12 })
  }
}

@Component
struct ShopItem {
  @ObjectLink shop: DataSourceStyleAStyleA;
  onShopSelect: (shopId: string, selected: boolean) => void = () => {
  };
  onProductSelect: (shopId: string, productId: string, selected: boolean) => void = () => {
  };
  onQuantityChange: (shopId: string, productId: string, quantity: number) => void = () => {
  };

  build() {
    Column() {
      Row() {
        Checkbox()
          .select(this.shop.isSelected)
          .margin({ right: 8 })
          .onChange((isChecked: boolean) => {
            this.onShopSelect(this.shop.id, isChecked);
          })
          .width(16)
          .height(16)
        if (this.shop.name.includes('自营')) {
          Text("自营")
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('app.color.brand_primary_JD_ShoppingCart'))
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2
            })
            .borderRadius(2)
            .margin({ right: 4 })
        }
        Text(this.shop.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_right_arrow_filled'))
          .width(8)
          .height(8)
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ top: 16, bottom: 4 })

      if (this.shop.promotions.length > 0) {
        ForEach(this.shop.promotions, (promotion: DataSourceStyleCStyleC) => {
          ShopPromotionInfo({
            promotion: promotion.text,
            detailText: promotion.detailText
          })
            .margin({ left: 30 })
        })
      }
      ForEach(this.shop.products, (product: DataSourceStyleBStyleB) => {
        ProductItem({
          product: product,
          shopId: this.shop.id,
          onProductSelect: this.onProductSelect,
          onQuantityChange: this.onQuantityChange
        })
        if (product.id !== this.shop.products[this.shop.products.length - 1].id) {
          Divider()
            .height(0.5)
            .color($r('sys.color.comp_divider'))
            .margin({ left: 96 })
        }
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })
    .backgroundColor($r('app.color.white_JD_ShoppingCart'))
    .borderRadius(16)
    .margin({ bottom: 8 })
  }
}

@Component
export struct ShoppingCartModule {
  @State model: DataSource = new DataSource();
  @State selectedTabIndex: number = 0;
  private tabItems: string[] = ["全部", "国家补贴", "送礼", "凑单", "降价", "筛选"];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Row() {
            Text("购物车")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(`(${this.model.totalItems})`)
              .fontSize(18)
              .fontColor($r('app.color.font_tertiary_JD_ShoppingCart'))
              .margin({ left: 4 })
          }

          Image($r('app.media.ic_right_arrow_filled'))
            .width(12)
            .height(12)
            .margin({ left: 4 })
          Blank()
          Text("管理")
            .fontSize(14)
            .fontColor($r('app.color.font_primary_JD_ShoppingCart'))
            .onClick(() => {
            })
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_public_more_black'))
              .width(20)
              .height(20)
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .margin({ left: 12 })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12
        })

        Row() {
          ForEach(this.tabItems, (item: string, index: number) => {
            Text(item)
              .fontSize(14)
              .fontColor(this.selectedTabIndex === index ? $r('app.color.brand_primary_JD_ShoppingCart') :
                $r('app.color.font_primary_JD_ShoppingCart'))
              .fontWeight(this.selectedTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8
              })
              .onClick(() => {
                this.selectedTabIndex = index;
              })
          })
          if (this.selectedTabIndex === this.tabItems.length - 1) {
            Image($r('app.media.ic_public_more_black'))
              .width(16)
              .height(16)
              .margin({ left: 4 })
          }
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().height(8).color($r('sys.color.comp_divider'))
        Scroll() {
          Column() {
            ForEach(this.model.shops, (shop: DataSourceStyleAStyleA) => {
              ShopItem({
                shop: shop,
                onShopSelect: (shopId: string, selected: boolean) => {
                  this.model.toggleSelectShop(shopId, selected);
                },
                onProductSelect: (shopId: string, productId: string, selected: boolean) => {
                  this.model.toggleSelectProduct(shopId, productId, selected);
                },
                onQuantityChange: (shopId: string, productId: string, quantity: number) => {
                  this.model.updateProductQuantity(shopId, productId, quantity);
                }
              })
            })
          }
          .width('100%')
          .padding({
            left: 12,
            right: 12,
            top: 8,
            bottom: 80
          })
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      Row() {
        Row() {
          Checkbox()
            .select(this.model.isAllSelected)
            .margin({ right: 8 })
            .onChange((isChecked: boolean) => {
              this.model.toggleSelectAll(isChecked);
            })
            .width(16)
            .height(16)
          Text("全选")
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
        }

        Column() {
          Row() {
            Text("合计:")
              .fontSize(14)
              .fontColor($r('app.color.font_primary_JD_ShoppingCart'))
            Text(`¥${this.model.getTotalPrice().toFixed(2)}`)
              .fontSize(16)
              .fontColor($r('app.color.brand_primary_JD_ShoppingCart'))
              .fontWeight(FontWeight.Bold)
          }

          if (this.model.getTotalDiscount() > 0) {
            Row() {
              Text("优惠:")
                .fontSize(12)
                .fontColor($r('app.color.font_tertiary_JD_ShoppingCart'))
              Text(`¥${this.model.getTotalDiscount().toFixed(2)}`)
                .fontSize(12)
                .fontColor($r('app.color.brand_primary_JD_ShoppingCart'))
            }
            .margin({ top: 2 })
          }
        }
        .padding({ left: 16 })

        Blank()
        Button("去结算", { type: ButtonType.Normal })
          .width(100)
          .height('80%')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.white_JD_ShoppingCart'))
          .backgroundColor($r('app.color.brand_primary_JD_ShoppingCart'))
          .borderRadius(8)
          .enabled(this.model.getSelectedCount() > 0)
          .opacity(this.model.getSelectedCount() > 0 ? 1 : 0.5)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor($r('app.color.white_JD_ShoppingCart'))
      .border({ width: { top: 0.5 }, color: $r('app.color.divider_primary_JD_ShoppingCart') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_secondary_JD_ShoppingCart'))
  }
}