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
    [$r(('app.media.realImageGen_education_1')), $r(('app.media.realImageGen_education_2')),
      $r(('app.media.realImageGen_education_8')),
      $r(('app.media.realImageGen_education_0'))];
  static readonly TITLES: string[] = ['精品课程', '限时优惠', '名师讲堂', '寒假特训'];
  static readonly CONTENTS: string[] =
    ['精选热门课程，助力学习成长', '报名立减300元，名额有限速抢', '一线名师授课，教学质量有保障',
      '寒假集训营，高效提升成绩'];

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
      for (let index = 0; index < Data.TITLES.length;
        index++) {
        modelList.push(new DataSource(
          Data.IMAGES[index],
          Data.TITLES[index],
          Data.CONTENTS[index]));
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private image: Resource;
  private title: string;
  private content: string;

  constructor(image: Resource, title: string, content: string) {
    this.image = image;
    this.title = title;
    this.content = content;
  }

  getTitle(): string {
    return this.title;
  }

  getContent(): string {
    return this.content;
  }

  getImage(): Resource {
    return this.image
  }
}