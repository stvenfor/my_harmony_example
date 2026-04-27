import LazyDataSource from '../util/LazyDataSource';

export class Data {
  private static instance: Data;
  lazyDataSource: LazyDataSource<DataSource> = new LazyDataSource();
  static readonly IMAGES: Resource[] = [$r(('app.media.realImageGen_news_5')), $r(('app.media.realImageGen_news_7')),
    $r(('app.media.realImageGen_news_5')), $r(('app.media.realImageGen_news_4')), $r(('app.media.realImageGen_news_9')),
    $r(('app.media.realImageGen_news_2')), $r(('app.media.realImageGen_news_7')), $r(('app.media.realImageGen_news_1')),
    $r(('app.media.realImageGen_news_5')), $r(('app.media.realImageGen_news_8'))];
  static readonly MAIN_TEXT: string[] =
    ['1. 全国多地迎来强降雨天气', '2. 新能源汽车销量同比增长超50%', '3. 国际科技峰会今日在京开幕',
      '4. 2024年奥运会筹备进入关键阶段', '5. 人工智能新算法突破医疗诊断瓶颈', '6. 全球粮食价格指数连续三月下降',
      '7. 我国成功发射新一代通信卫星', '8. 跨境电商新政助力中小企业出海', '9. 文旅部推出十条精品旅游线路',
      '10. 量子计算研究取得重大进展'];
  static readonly DESCRIPTION_TEXT: string[] =
    ['热度值：985万', '热度值：872万', '热度值：756万', '热度值：743万', '热度值：698万', '热度值：632万', '热度值：587万',
      '热度值：534万', '热度值：521万', '热度值：498万'];
  static readonly TAG_TEXTS_LIST: string[][] =
    [['999+万人已读', '都市', '已完结'], ['999+万人已读', '都市', '已完结'],
      ['999+万人已读', '都市', '已完结'], ['999+万人已读', '都市', '已完结'],
      ['999+万人已读', '都市', '已完结'], ['999+万人已读', '都市', '已完结']];
  static readonly TAG_TEXT_COLORS_LIST: Color[][] =
    [[Color.Brown, Color.Green, Color.Gray], [Color.Brown, Color.Green, Color.Gray],
      [Color.Brown, Color.Green, Color.Gray], [Color.Brown, Color.Green, Color.Gray],
      [Color.Brown, Color.Green, Color.Gray], [Color.Brown, Color.Green, Color.Gray]];

  constructor() {
  }

  public static getInstance(): Data {
    if (!Data.instance) {
      Data.instance =
        new Data();
    }
    return Data.instance;
  }

  /**
   * Data loaded on current view converts network data into rendering data
   */
  getResources(): Promise<void> {
    /**
     * use your web request here
     */
    return new Promise((resolve: Function) => {
      const modelList: Array<DataSource> = [];
      for (let index = 0; index < Data.IMAGES.length;
        index++) {
        modelList.push(new DataSource(
          Data.IMAGES[index],
          Data.MAIN_TEXT[index],
          Data.DESCRIPTION_TEXT[index],
          Data.TAG_TEXTS_LIST[index],
          Data.TAG_TEXT_COLORS_LIST[index]));
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private image: Resource;
  private mainText: string;
  private descriptionText: string;
  private tagTextList: string[];
  private tagTextColorList: Color[];

  constructor(image: Resource, mainText: string,
    descriptionText: string, tagTextList: string[], tagTextColorList: Color[]) {
    this.image = image;
    this.mainText = mainText;
    this.descriptionText = descriptionText;
    this.tagTextList = tagTextList;
    this.tagTextColorList = tagTextColorList;
  }

  getImage(): Resource {
    return this.image;
  }

  getMainText(): string {
    return this.mainText;
  }

  getDescriptionText(): string {
    return this.descriptionText;
  }

  getTagTextList(): string[] {
    return this.tagTextList;
  }

  getTagTextColorList(): Color[] {
    return this.tagTextColorList;
  }
}