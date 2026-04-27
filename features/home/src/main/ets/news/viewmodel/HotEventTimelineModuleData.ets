/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import LazyDataSource from '../util/LazyDataSource';

export class Data {
  private static instance: Data;
  lazyDataSource: LazyDataSource<DataSource> = new LazyDataSource();
  static readonly IMAGES: Resource[] = [$r(('app.media.realImageGen_news_7')), $r(('app.media.realImageGen_news_9')),
    $r(('app.media.realImageGen_news_5')), $r(('app.media.realImageGen_news_5'))];
  static readonly DESCRIPTION_TEXT: string[] =
    ['习近平出席亚太经合组织领导人非正式会议', '央行宣布下调存款准备金率0.5个百分点', '我国成功发射遥感四十号卫星',
      '全国多地出现强降雨天气'];
  static readonly TIMES: string[] = ['09:00', '11:30', '14:15', '16:45'];

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
          Data.DESCRIPTION_TEXT[index],
          Data.TIMES[index],
        ));
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private image: Resource;
  private descriptionText: string;
  private time: string;

  constructor(image: Resource, descriptionText: string, time: string) {
    this.image = image;
    this.descriptionText = descriptionText;
    this.time = time;
  }

  getImage(): Resource {
    return this.image;
  }

  getDescriptionText(): string {
    return this.descriptionText;
  }

  getTime(): string {
    return this.time;
  }
}