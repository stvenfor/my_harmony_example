import LazyDataSource from '../util/LazyDataSource';

export class DataSourceStyleBStyleB {
  private id: string;
  private title: string;
  private description: string;
  private price: number;
  private membershipPrice?: number;
  private image: Resource;
  private labels: string[];

  constructor(id: string, title: string, description: string, price: number, image: Resource, labels: string[],
    membershipPrice?: number) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.price = price;
    this.image = image;
    this.labels = labels;
    this.membershipPrice = membershipPrice;
  }

  getId(): string {
    return this.id;
  }

  getTitle(): string {
    return this.title;
  }

  getDescription(): string {
    return this.description;
  }

  getPrice(): number {
    return this.price;
  }

  getMembershipPrice(): number | undefined {
    return this.membershipPrice;
  }

  getImage(): Resource {
    return this.image;
  }

  getLabels(): string[] {
    return this.labels;
  }
}

export class DataSourceStyleAStyleA {
  private title: string;
  private items: DataSourceStyleBStyleB[];

  constructor(title: string, items: DataSourceStyleBStyleB[]) {
    this.title = title;
    this.items = items;
  }

  getTitle(): string {
    return this.title;
  }

  getItems(): DataSourceStyleBStyleB[] {
    return this.items;
  }
}

export class DataSource {
  private static instance: DataSource;
  lazyDataSource: LazyDataSource<DataSourceStyleAStyleA> = new LazyDataSource();
  static readonly CATEGORIES: string[] = ['手机数码', '电脑办公', '家用电器', '家用电器', '家用电器', '家用电器'];
  static readonly CATEGORIES_PHOTO: Resource[] = [
    $r('app.media.recommend1'),
    $r('app.media.recommend2'),
    $r('app.media.recommend3'),
    $r('app.media.recommend4'),
    $r('app.media.recommend5')
    ,
    $r('app.media.recommend1')];
  static readonly SIDE_MENU: string[] = ['品牌旗舰店', '耳机配件', '笔记本', '台式机', '厨房电器', '生活电器'];
  static readonly SUB_MENU1: string[] = ['智能手机', '平板电脑', '笔记本电脑', '打印机', '冰箱', '空调'];
  static readonly TOP_ICONS: Resource[] = [
    $r('app.media.recommend1'),
    $r('app.media.recommend2'),
    $r('app.media.recommend3'),
    $r('app.media.recommend4'),
    $r('app.media.recommend5')
    ,
    $r('app.media.recommend1')];
  static readonly ITEM_TITLES: string[] =
    ['iPhone 15 Pro', '华为MateBook', '小米空气净化器', '小米空气净化器', '小米空气净化器', '小米空气净化器'];
  static readonly ITEM_DESCRIPTIONS: string[] =
    ['最新A17芯片，钛金属机身', '13代酷睿处理器，2.8K全面屏', '高效过滤PM2.5，智能互联', '高效过滤PM2.5，智能互联',
      '高效过滤PM2.5，智能互联', '高效过滤PM2.5，智能互联'];
  static readonly ITEM_PRICES: number[] = [179, 199, 199];
  static readonly ITEM_MEMBERSHIP_PRICES: (number | undefined)[] = [undefined, 168, undefined];
  static readonly ITEM_IMAGES: Resource[] =
    [$r(('app.media.realImageGen_shop_4')), $r(('app.media.realImageGen_shop_4')),
      $r(('app.media.realImageGen_shop_6')), $r(('app.media.realImageGen_shop_6')),
      $r(('app.media.realImageGen_shop_1')), $r(('app.media.realImageGen_shop_2'))];
  static readonly ITEM_LABELS: string[][] = [['自营'], ['自营'], ['新品']];
  private _gift_box_groups: DataSourceStyleAStyleA[] = [];

  public get gift_box_groups(): DataSourceStyleAStyleA[] {
    return this._gift_box_groups;
  }

  private constructor() {
    DataSource.SIDE_MENU.forEach((menuTitle,) => {
      let itemList: DataSourceStyleBStyleB[] = [];
      DataSource.ITEM_TITLES.forEach((_, itemIndex) => {
        itemList.push(new DataSourceStyleBStyleB(
          itemIndex.toString(),
          DataSource.ITEM_TITLES[itemIndex % DataSource.ITEM_TITLES.length],
          DataSource.ITEM_DESCRIPTIONS[itemIndex % DataSource.ITEM_DESCRIPTIONS.length],
          DataSource.ITEM_PRICES[itemIndex % DataSource.ITEM_PRICES.length],
          DataSource.ITEM_IMAGES[itemIndex % DataSource.ITEM_IMAGES.length],
          DataSource.ITEM_LABELS[itemIndex % DataSource.ITEM_LABELS.length],
          DataSource.ITEM_MEMBERSHIP_PRICES[itemIndex % DataSource.ITEM_MEMBERSHIP_PRICES.length]
        ));
      });
      this._gift_box_groups.push(new DataSourceStyleAStyleA(menuTitle, itemList));
    });
    this.lazyDataSource.pushArrayData(this._gift_box_groups);
  }

  public static getInstance(): DataSource {
    if (!DataSource.instance) {
      DataSource.instance = new DataSource();
    }
    return DataSource.instance;
  }

  getResources(): Promise<void> {
    return Promise.resolve();
  }
}