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
  static readonly IMAGES: Resource[] =
    [$r(('app.media.realImageGen_travel_17')), $r(('app.media.realImageGen_travel_1')),
      $r(('app.media.realImageGen_travel_14')),
      $r(('app.media.realImageGen_travel_7'))];
  static readonly TITLES: string[] = ['西藏之旅', '海岛度假', '古城探秘', '美食地图'];
  static readonly AVATARS: Resource[] =
    [$r('app.media.user_photo'), $r('app.media.user_photo'), $r('app.media.user_photo'),
      $r('app.media.user_photo')];
  static readonly NAMES: string[] = ['旅行达人小王', '背包客小李', '摄影爱好者小张', '美食博主小赵'];
  static readonly FAVOR_IMAGES: Resource[] =
    [$r('app.media.ic_public_favor_black'), $r('app.media.ic_public_favor_black'),
      $r('app.media.ic_public_favor_black'),
      $r('app.media.ic_public_favor_black')];
  static FAVOR_COUNTS: number[] =
    [123, 321, 232, 11, 33, 666];

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
          Data.TITLES[index],
          Data.AVATARS[index],
          Data.NAMES[index],
          Data.FAVOR_IMAGES[index],
          Data.FAVOR_COUNTS[index]));
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private image: Resource;
  private title: string;
  private avatar: Resource;
  private name: string;
  private favorImage: Resource;
  private favorCounts: number;

  constructor(image: Resource, title: string, avatar: Resource, name: string, favorImage: Resource,
    favorCounts: number) {
    this.image = image;
    this.title = title;
    this.avatar = avatar;
    this.name = name;
    this.favorImage = favorImage;
    this.favorCounts = favorCounts;
  }

  getImage(): Resource {
    return this.image
  }

  getTitle(): string {
    return this.title;
  }

  getAvatar(): Resource {
    return this.avatar;
  }

  getName(): string {
    return this.name;
  }

  getFavorImage(): Resource {
    return this.favorImage;
  }

  getFavorCounts(): number {
    return this.favorCounts;
  }
}