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

export class DataSourceStyleAStyleA {
  private static instance: DataSourceStyleAStyleA;
  lazyDataSource1: LazyDataSource<DataSource> = new LazyDataSource();
  lazyDataSource2: LazyDataSource<DataSource> = new LazyDataSource();
  lazyDataSource3: LazyDataSource<DataSource> = new LazyDataSource();
  static readonly IMAGES: Resource[] = [$r(('app.media.realImageGen_news_4')), $r(('app.media.realImageGen_news_2')),
    $r(('app.media.realImageGen_news_0')),
    $r(('app.media.realImageGen_news_5'))];
  static readonly TITLES: string[] = ['财经', '科技', '体育', '娱乐'];
  static readonly DESCRIPTIONS: string[] = ['', '', '', ''];

  constructor() {
  }

  public static getInstance(): DataSourceStyleAStyleA {
    if (!DataSourceStyleAStyleA.instance) {
      DataSourceStyleAStyleA.instance =
        new DataSourceStyleAStyleA();
    }
    return DataSourceStyleAStyleA.instance;
  }

  /**
   * Data loaded on current view converts network data into rendering data
   */
  getResources(): Promise<void> {
    /**
     * use your web request here
     */
    return new Promise((resolve: Function) => {
      const modelList1: Array<DataSource> = [];
      const modelList2: Array<DataSource> = [];
      const modelList3: Array<DataSource> = [];
      for (let index = 0; index < DataSourceStyleAStyleA.TITLES.length;
        index++) {
        modelList1.push(new DataSource(
          DataSourceStyleAStyleA.IMAGES[index],
          DataSourceStyleAStyleA.TITLES[index],
          DataSourceStyleAStyleA.DESCRIPTIONS[index]));
        modelList2.push(new DataSource(
          DataSourceStyleAStyleA.IMAGES[index],
          DataSourceStyleAStyleA.TITLES[index],
          DataSourceStyleAStyleA.DESCRIPTIONS[index]));
        modelList3.push(new DataSource(
          DataSourceStyleAStyleA.IMAGES[index],
          DataSourceStyleAStyleA.TITLES[index],
          DataSourceStyleAStyleA.DESCRIPTIONS[index]));
      }
      this.lazyDataSource1.pushArrayData(modelList1);
      this.lazyDataSource2.pushArrayData(modelList2);
      this.lazyDataSource3.pushArrayData(modelList3);
      resolve();
    });
  }
}

export class DataSource {
  private icon: Resource;
  private title: string;
  private description: string;

  constructor(icon: Resource, title: string, description: string) {
    this.icon = icon;
    this.title = title;
    this.description = description;
  }

  getIcon(): Resource {
    return this.icon;
  }

  getTitle(): string {
    return this.title;
  }

  getDescription(): string {
    return this.description;
  }
}