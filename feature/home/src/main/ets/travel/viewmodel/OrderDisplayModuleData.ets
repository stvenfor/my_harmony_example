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
  static readonly PRICES: string[] = ['¥1280', '¥2580'];
  static readonly TITLES: string[] = ['北京故宫', '北京故宫'];
  static readonly ORDER_STATUS: string[] = ['待出行', '已完成'];
  static readonly ORDER_TIMES: string[] = ['2023-10-05 14:30', '2023-09-20 09:15'];

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
      for (let index = 0; index < Data.PRICES.length;
        index++) {
        modelList.push(new DataSource(
          Data.PRICES[index],
          Data.TITLES[index],
          Data.ORDER_STATUS[index],
          Data.ORDER_TIMES[index]));
      }
      this.lazyDataSource.pushArrayData(modelList);
      resolve();
    });
  }
}

export class DataSource {
  private price: string;
  private title: string;
  private orderStatus: string;
  private orderTime: string;

  constructor(price: string, title: string, orderStatus: string, orderTime: string) {
    this.price = price
    this.orderStatus = orderStatus
    this.title = title
    this.orderTime = orderTime
  }

  getPrice(): string {
    return this.price;
  }

  getOrderStatus(): string {
    return this.orderStatus;
  }

  getTitle(): string {
    return this.title;
  }

  getOrderTime(): string {
    return this.orderTime;
  }
}