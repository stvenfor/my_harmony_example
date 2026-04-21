import LazyDataSource from '../util/LazyDataSource';

export class DataSourceStyleAStyleA {
  private static instance: DataSourceStyleAStyleA;
  lazyDataSource: LazyDataSource<DataSource> = new LazyDataSource();
  static readonly IMAGES: Resource[] = [
    $r(('app.media.realImageGen_shop_0')),
    $r(('app.media.realImageGen_shop_5')),
    $r(('app.media.realImageGen_shop_3')),
    $r(('app.media.realImageGen_shop_0'))
  ];
  static readonly TITLES: string[] = ['智能手机', '无线耳机', '运动鞋', '保温杯'];
  static readonly SUBTITLES: string[] =
    ['旗舰机型 限时特惠', '降噪蓝牙 持久续航', '透气舒适 防滑耐磨', '不锈钢内胆 保温保冷'];
  static readonly PRICE_LABELS: string[] = ['2999', '399', '259', '89'];
  static readonly ORIGINAL_PRICES: string[] = ['3599', '499', '329', '129'];
  static readonly TAGS: string[] = ['限时5折', '买一送一', '新品首发', '满减优惠'];
  static readonly STOCK_INFO: string[] = ['仅剩10件', '库存充足', '仅剩5件', '库存紧张'];
  static readonly LIMITS: string[] = ['限购2件', '每人限1件', '限购3件', '限购1件'];

  private constructor() {
  }

  public static getInstance(): DataSourceStyleAStyleA {
    if (!DataSourceStyleAStyleA.instance) {
      DataSourceStyleAStyleA.instance = new DataSourceStyleAStyleA();
    }
    return DataSourceStyleAStyleA.instance;
  }

  getResources(): Promise<void> {
    return new Promise((resolve: Function, reject: Function) => {
      try {
        const modelList: Array<DataSource> = [];
        for (let index = 0; index < DataSourceStyleAStyleA.IMAGES.length; index++) {
          modelList.push(new DataSource(
            DataSourceStyleAStyleA.IMAGES[index],
            DataSourceStyleAStyleA.TITLES[index],
            DataSourceStyleAStyleA.SUBTITLES[index],
            DataSourceStyleAStyleA.PRICE_LABELS[index],
            DataSourceStyleAStyleA.ORIGINAL_PRICES[index],
            DataSourceStyleAStyleA.TAGS[index],
            DataSourceStyleAStyleA.STOCK_INFO[index],
            DataSourceStyleAStyleA.LIMITS[index]
          ));
        }
        this.lazyDataSource.pushArrayData(modelList);
        resolve();
      } catch (error) {
        reject(error);
      }
    });
  }
}

export class DataSource {
  private image: Resource;
  private title: string;
  private subtitle: string;
  private priceLabel: string;
  private originalPrice: string;
  private tag: string;
  private stockInfo: string;
  private limit: string;

  constructor(
    image: Resource,
    title: string,
    subtitle: string,
    priceLabel: string,
    originalPrice: string,
    tag: string,
    stockInfo: string,
    limit: string
  ) {
    this.image = image;
    this.title = title;
    this.subtitle = subtitle;
    this.priceLabel = priceLabel;
    this.originalPrice = originalPrice;
    this.tag = tag;
    this.stockInfo = stockInfo;
    this.limit = limit;
  }

  getImage(): Resource {
    return this.image;
  }

  getTitle(): string {
    return this.title;
  }

  getSubtitle(): string {
    return this.subtitle;
  }

  getPriceLabel(): string {
    return this.priceLabel;
  }

  getOriginalPrice(): string {
    return this.originalPrice;
  }

  getTag(): string {
    return this.tag;
  }

  getStockInfo(): string {
    return this.stockInfo;
  }

  getLimit(): string {
    return this.limit;
  }
}