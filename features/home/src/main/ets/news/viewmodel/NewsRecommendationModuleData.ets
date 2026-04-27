export enum DataSourceStyleBStyleB {
  AUDIO = '声音',
  SPECIAL = '专辑'
}

export class DataSourceStyleAStyleA {
  private id: string;
  private title: string;
  private cover: Resource;
  private type: DataSourceStyleBStyleB;

  constructor(id: string, title: string, cover: Resource, type: DataSourceStyleBStyleB) {
    this.id = id;
    this.title = title;
    this.cover = cover;
    this.type = type;
  }

  getId(): string {
    return this.id;
  }

  getTitle(): string {
    return this.title;
  }

  getCover(): Resource {
    return this.cover;
  }

  getType(): DataSourceStyleBStyleB {
    return this.type;
  }
}

export class DataSource {
  private playlists: DataSourceStyleAStyleA[] = [];
  private title: string = '听单';
  static readonly PLAYLIST_IDS: string[] =
    ['news_hot', 'news_politics', 'news_tech', 'news_sports', 'news_entertainment', 'news_finance'];
  static readonly PLAYLIST_TITLES: string[] = ['热点新闻', '时政要闻', '科技前沿', '体育赛事', '娱乐八卦', '财经资讯'];
  static readonly PLAYLIST_COVERS: Resource[] = [
    $r(('app.media.realImageGen_news_5')),
    $r(('app.media.realImageGen_news_5')),
    $r(('app.media.realImageGen_news_4')),
    $r(('app.media.realImageGen_news_3')),
    $r(('app.media.realImageGen_news_3'))
    ,
    $r(('app.media.realImageGen_news_4'))];
  static readonly PLAYLIST_TYPES: DataSourceStyleBStyleB[] = [
    DataSourceStyleBStyleB.AUDIO,
    DataSourceStyleBStyleB.AUDIO,
    DataSourceStyleBStyleB.AUDIO,
    DataSourceStyleBStyleB.SPECIAL,
    DataSourceStyleBStyleB.AUDIO
  ];

  constructor() {
    this.initPlaylists();
  }

  private initPlaylists(): void {
    for (let i = 0; i < DataSource.PLAYLIST_IDS.length; i++) {
      this.playlists.push(new DataSourceStyleAStyleA(
        DataSource.PLAYLIST_IDS[i],
        DataSource.PLAYLIST_TITLES[i],
        DataSource.PLAYLIST_COVERS[i],
        DataSource.PLAYLIST_TYPES[i]
      ));
    }
  }

  getTitle(): string {
    return this.title;
  }

  getPlaylists(): DataSourceStyleAStyleA[] {
    return this.playlists;
  }
}