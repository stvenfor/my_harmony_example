@Observed
export class DataSourceStyleAStyleA {
  id: string;
  name: string;
  isSelected: boolean = false;
  products: DataSourceStyleBStyleB[] = [];
  promotions: DataSourceStyleCStyleC[] = [];

  constructor(id: string, name: string, products: DataSourceStyleBStyleB[] = [],
    promotions: DataSourceStyleCStyleC[] = []) {
    this.id = id;
    this.name = name;
    this.products = products;
    this.promotions = promotions;
  }
}

export class DataSourceStyleCStyleC {
  id: string;
  text: string;
  detailText: string;
  type: string; // 'discount' | 'gift'
  threshold: number;
  discount: number;

  constructor(id: string, text: string, detailText: string, type: string, threshold: number, discount: number = 0) {
    this.id = id;
    this.text = text;
    this.detailText = detailText;
    this.type = type;
    this.threshold = threshold;
    this.discount = discount;
  }
}

@Observed
export class DataSourceStyleBStyleB {
  id: string;
  name: string;
  desc: string;
  image: Resource;
  price: number;
  originalPrice: number;
  tags: string[] = [];
  isSelected: boolean = false;
  quantity: number = 1;
  specs: string = "";
  warranty: string = "";
  hasPromotion: boolean = false;
  promotionInfo: string = "";
  priceProtection: boolean = false;
  nationSubsidy: boolean = false;
  nationSubsidyAmount: number = 0;

  constructor(id: string, name: string, desc: string, image: Resource, price: number, originalPrice: number) {
    this.id = id;
    this.name = name;
    this.desc = desc;
    this.image = image;
    this.price = price;
    this.originalPrice = originalPrice;
  }
}

@Observed
export class DataSource {
  shops: DataSourceStyleAStyleA[] = [];
  totalPrice: number = 0;
  totalDiscount: number = 0;
  totalSelected: number = 0;
  totalItems: number = 0;
  isAllSelected: boolean = false;

  constructor() {
    this.initData();
    this.updateTotals();
  }

  private initData(): void {
    const jdEsportsShop = new DataSourceStyleAStyleA(
      "shop1",
      "手机官方旗舰店",
      [
        this.createOppoProduct()
      ],
      [
        new DataSourceStyleCStyleC("promo1", "满1000减100", "满1000元减100元", "discount", 1000, 100)
      ]
    );
    const intelShop = new DataSourceStyleAStyleA(
      "shop2",
      "CPU官方旗舰店",
      [
        this.createIntelProduct()
      ],
      [
        new DataSourceStyleCStyleC("promo2", "7天价保", "下单后7天内价格保护", "protection", 0)
      ]
    );
    const zhitaiShop = new DataSourceStyleAStyleA(
      "shop3",
      "存储自营旗舰店",
      [
        this.createZhitaiProduct()
      ],
      [
        new DataSourceStyleCStyleC("promo3", "满4000元送赠品", "满7500元送赠品", "gift", 4000),
      ]
    );
    this.shops = [jdEsportsShop, intelShop, zhitaiShop];
    this.updateTotalItems();
  }

  private createOppoProduct(): DataSourceStyleBStyleB {
    const product = new DataSourceStyleBStyleB(
      "prod1",
      "60 Pro 【国家补贴】新品",
      "白，8GB+256GB",
      $r('app.media.startIcon'),
      1399,
      1499
    );
    product.tags = ["国家补贴", "5G"];
    product.specs = "白，8GB+256GB";
    product.warranty = "7天价保";
    product.hasPromotion = true;
    product.promotionInfo = "满1000减100 ";
    product.nationSubsidy = true;
    product.nationSubsidyAmount = 1189.15;
    return product;
  }

  private createIntelProduct(): DataSourceStyleBStyleB {
    const product = new DataSourceStyleBStyleB(
      "prod2",
      "CPU处理器",
      "盒装【五年原保】",
      $r('app.media.startIcon'),
      2499,
      2499
    );
    product.specs = "盒装【五年原保】";
    product.warranty = "7天价保";
    product.hasPromotion = false;
    return product;
  }

  private createZhitaiProduct(): DataSourceStyleBStyleB {
    const product = new DataSourceStyleBStyleB(
      "prod3",
      "存储 4TB SSD",
      "TiPlus 全能之作，【4TB】",
      $r('app.media.startIcon'),
      1859,
      1859
    );
    product.tags = ["自营"];
    product.specs = "TiPlus，【4TB】";
    product.warranty = "7天价保";
    product.hasPromotion = true;
    product.promotionInfo = "满4000元送赠品 >";
    return product;
  }

  private updateTotalItems(): void {
    let count = 0;
    this.shops.forEach(shop => {
      count += shop.products.length;
    });
    this.totalItems = count;
  }

  updateTotals(): void {
    let price = 0;
    let discount = 0;
    let selected = 0;
    this.shops.forEach(shop => {
      shop.products.forEach(product => {
        if (product.isSelected) {
          price += product.price * product.quantity;
          discount += (product.originalPrice - product.price) * product.quantity;
          selected++;
        }
      });
    });
    this.totalPrice = price;
    this.totalDiscount = discount;
    this.totalSelected = selected;
    this.checkAllSelected();
  }

  checkAllSelected(): void {
    if (this.totalItems === 0) {
      this.isAllSelected = false;
      return;
    }
    this.isAllSelected = this.totalSelected === this.totalItems;
  }

  toggleSelectAll(selected: boolean): void {
    this.isAllSelected = selected;
    this.shops.forEach(shop => {
      shop.isSelected = selected;
      shop.products.forEach(product => {
        product.isSelected = selected;
      });
    });
    this.updateTotals();
  }

  toggleSelectShop(shopId: string, selected: boolean): void {
    const shop = this.shops.find(s => s.id === shopId);
    if (shop) {
      shop.isSelected = selected;
      shop.products.forEach(product => {
        product.isSelected = selected;
      });
      this.updateTotals();
    }
  }

  toggleSelectProduct(shopId: string, productId: string, selected: boolean): void {
    const shop = this.shops.find(s => s.id === shopId);
    if (shop) {
      const product = shop.products.find(p => p.id === productId);
      if (product) {
        product.isSelected = selected;
        const allProductsSelected = shop.products.every(p => p.isSelected);
        shop.isSelected = allProductsSelected;
        this.updateTotals();
      }
    }
  }

  updateProductQuantity(shopId: string, productId: string, quantity: number): void {
    if (quantity < 1) return;
    const shop = this.shops.find(s => s.id === shopId);
    if (shop) {
      const product = shop.products.find(p => p.id === productId);
      if (product) {
        product.quantity = quantity;
        this.updateTotals();
      }
    }
  }

  removeProduct(shopId: string, productId: string): void {
    const shop = this.shops.find(s => s.id === shopId);
    if (shop) {
      const index = shop.products.findIndex(p => p.id === productId);
      if (index !== -1) {
        shop.products.splice(index, 1);
        if (shop.products.length === 0) {
          const shopIndex = this.shops.findIndex(s => s.id === shopId);
          if (shopIndex !== -1) {
            this.shops.splice(shopIndex, 1);
          }
        } else {
          const allProductsSelected = shop.products.every(p => p.isSelected);
          shop.isSelected = allProductsSelected;
        }
        this.updateTotalItems();
        this.updateTotals();
      }
    }
  }

  getSelectedCount(): number {
    return this.totalSelected;
  }

  getTotalPrice(): number {
    return this.totalPrice;
  }

  getTotalDiscount(): number {
    return this.totalDiscount;
  }
}