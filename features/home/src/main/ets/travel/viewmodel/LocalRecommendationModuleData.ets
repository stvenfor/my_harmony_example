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
  static readonly TITLES1: string[] = ['故宫博物院', '八达岭长城'];
  static readonly DETAILS1: string[] = ['中国明清两代的皇家宫殿，世界文化遗产，拥有丰富的历史文物收藏',
    '中国古代伟大的防御工程，世界新七大奇迹之一，适合徒步观光'];
  static readonly IMAGES1: Resource[] =
    [$r(('app.media.realImageGen_travel_18')), $r(('app.media.realImageGen_travel_17'))];
  static readonly IMAGE_DETAILS1: string[] = ['中国明清两代的皇家宫殿，世界文化遗产，拥有丰富的历史文物收藏',
    '中国古代伟大的防御工程，世界新七大奇迹之一，适合徒步观光'];
  static readonly TITLES2: string[] = ['颐和园', '天坛公园'];
  static readonly DETAILS2: string[] = ['清代皇家园林，以昆明湖、万寿山为基址，融合江南园林设计风格',
    '明清两代皇帝祭天祈谷的场所，建筑精巧，具有深厚的文化内涵'];
  static readonly IMAGES2: Resource[] =
    [$r(('app.media.realImageGen_travel_17')), $r(('app.media.realImageGen_travel_7'))];
  static readonly IMAGE_DETAILS2: string[] = ['清代皇家园林，以昆明湖、万寿山为基址，融合江南园林设计风格',
    '明清两代皇帝祭天祈谷的场所，建筑精巧，具有深厚的文化内涵'];

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
      for (let index = 0; index < Data.TITLES1.length;
        index++) {
        modelList.push(new DataSource(
          Data.TITLES1[index],
          Data.IMAGES1[index],
          Data.IMAGE_DETAILS1[index],
          Data.DETAILS1[index],
          Data.TITLES2[index],
          Data.IMAGES2[index],
          Data.IMAGE_DETAILS2[index],
          Data.DETAILS2[index]))
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private title1: string;
  private image1: Resource;
  private imageDetail1: string;
  private detail1: string;
  private title2: string;
  private image2: Resource;
  private imageDetail2: string;
  private detail2: string;

  constructor(title1: string, image1: Resource, imageDetail1: string, detail1: string, title2: string, image2: Resource,
    imageDetail2: string, detail2: string) {
    this.title1 = title1;
    this.image1 = image1;
    this.imageDetail1 = imageDetail1;
    this.detail1 = detail1;
    this.title2 = title2;
    this.image2 = image2;
    this.imageDetail2 = imageDetail2;
    this.detail2 = detail2;
  }

  getTitle1(): string {
    return this.title1;
  }

  getImage1(): Resource {
    return this.image1;
  }

  getImageDetail1(): string {
    return this.imageDetail1;
  }

  getDetail1(): string {
    return this.detail1;
  }

  getTitle2(): string {
    return this.title2;
  }

  getImage2(): Resource {
    return this.image2;
  }

  getImageDetail2(): string {
    return this.imageDetail2;
  }

  getDetail2(): string {
    return this.detail2;
  }
}