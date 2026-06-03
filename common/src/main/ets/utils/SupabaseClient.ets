 /**
 * Supabase 客户端封装
 * 基于 axios 实现 Supabase REST API 调用
 */

import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from '@ohos/axios';

const TAG: string = 'SupabaseClient';

/** Supabase 配置接口 */
export interface SupabaseConfig {
  readonly projectUrl: string;
  readonly apiKey: string;
}

/** Supabase 排序参数 */
export interface SupabaseOrderParams {
  column: string;
  ascending?: boolean;
}

/** Supabase 查询参数 */
export interface SupabaseQueryParams {
  select?: string;
  eq?: Record<string, string | number | boolean>;
  neq?: Record<string, string | number | boolean>;
  gt?: Record<string, string | number>;
  gte?: Record<string, string | number>;
  lt?: Record<string, string | number>;
  lte?: Record<string, string | number>;
  like?: Record<string, string>;
  ilike?: Record<string, string>;
  is?: Record<string, string | null>;
  in?: Record<string, Array<string | number>>;
  order?: SupabaseOrderParams;
  limit?: number;
  offset?: number;
}

/** Supabase 响应结果 */
export interface SupabaseResult<T> {
  data: T | null;
  error: SupabaseError | null;
}

/** Supabase 错误响应数据 */
interface SupabaseErrorData {
  message?: string;
  code?: string;
  details?: string;
  hint?: string;
}

/** Axios 错误响应数据接口 */
interface AxiosErrorData {
  data?: SupabaseErrorData;
}

/** Axios 错误响应接口 */
interface AxiosErrorResponse {
  response?: AxiosErrorData;
  message?: string;
}

/** Supabase 错误信息 */
export interface SupabaseError {
  message: string;
  code?: string;
  details?: string;
  hint?: string;
}

/**
 * Supabase 客户端类
 * 提供基础的 CRUD 操作
 */
export class SupabaseClient {
  private readonly instance: AxiosInstance;
  private readonly apiKey: string;

  constructor(config: SupabaseConfig) {
    this.apiKey = config.apiKey;
    this.instance = axios.create({
      baseURL: `${config.projectUrl}/rest/v1`,
      timeout: 30000,
      headers: {
        'apikey': config.apiKey,
        'Authorization': `Bearer ${config.apiKey}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    // 响应拦截器
    this.instance.interceptors.response.use(
      (response: AxiosResponse) => response,
      (error: Error) => {
        console.error(`${TAG}: Request failed`, error);
        return Promise.reject(error);
      }
    );
  }

  /**
   * 从表中查询数据
   * @param table 表名
   * @param params 查询参数
   */
  async from<T>(table: string, params?: Object): Promise<SupabaseResult<T[]>> {
    try {
      let url = `/${table}`;
      const queryParams: Record<string, string> = {};

      // 将 params 转换为可访问的对象
      const paramsObj = params as SupabaseQueryParams;

      // 构建查询参数
      if (paramsObj?.select) {
        queryParams['select'] = paramsObj.select;
      }

      // 过滤条件
      if (paramsObj?.eq) {
        Object.keys(paramsObj.eq).forEach(key => {
          queryParams[key] = `eq.${paramsObj.eq![key]}`;
        });
      }

      if (paramsObj?.neq) {
        Object.keys(paramsObj.neq).forEach(key => {
          queryParams[key] = `neq.${paramsObj.neq![key]}`;
        });
      }

      if (paramsObj?.gt) {
        Object.keys(paramsObj.gt).forEach(key => {
          queryParams[key] = `gt.${paramsObj.gt![key]}`;
        });
      }

      if (paramsObj?.gte) {
        Object.keys(paramsObj.gte).forEach(key => {
          queryParams[key] = `gte.${paramsObj.gte![key]}`;
        });
      }

      if (paramsObj?.lt) {
        Object.keys(paramsObj.lt).forEach(key => {
          queryParams[key] = `lt.${paramsObj.lt![key]}`;
        });
      }

      if (paramsObj?.lte) {
        Object.keys(paramsObj.lte).forEach(key => {
          queryParams[key] = `lte.${paramsObj.lte![key]}`;
        });
      }

      if (paramsObj?.like) {
        Object.keys(paramsObj.like).forEach(key => {
          queryParams[key] = `like.${paramsObj.like![key]}`;
        });
      }

      if (paramsObj?.ilike) {
        Object.keys(paramsObj.ilike).forEach(key => {
          queryParams[key] = `ilike.${paramsObj.ilike![key]}`;
        });
      }

      if (paramsObj?.is) {
        Object.keys(paramsObj.is).forEach(key => {
          queryParams[key] = `is.${paramsObj.is![key]}`;
        });
      }

      if (paramsObj?.in) {
        Object.keys(paramsObj.in).forEach(key => {
          queryParams[key] = `in.(${paramsObj.in![key].join(',')})`;
        });
      }

      // 排序
      if (paramsObj?.order) {
        const orderStr = `${paramsObj.order.column}.${paramsObj.order.ascending ? 'asc' : 'desc'}`;
        queryParams['order'] = orderStr;
      }

      // 分页
      if (paramsObj?.limit !== undefined) {
        queryParams['limit'] = paramsObj.limit.toString();
      }

      if (paramsObj?.offset !== undefined) {
        queryParams['offset'] = paramsObj.offset.toString();
      }

      // 构建完整 URL
      const queryString = Object.keys(queryParams)
        .map(key => `${key}=${queryParams[key]}`)
        .join('&');
      
      if (queryString) {
        url += `?${queryString}`;
      }

      const response: AxiosResponse = await this.instance.get(url);
      
      return {
        data: response.data as T[],
        error: null
      };
    } catch (err) {
      const error = err as AxiosErrorResponse;
      console.error(`${TAG}: Query failed for table ${table}`, error);
      return {
        data: null,
        error: this.parseError(error)
      };
    }
  }

  /**
   * 插入数据
   * @param table 表名
   * @param data 要插入的数据
   */
  async insert<T>(table: string, data: Object): Promise<SupabaseResult<T>> {
    try {
      const response: AxiosResponse = await this.instance.post(`/${table}`, data);
      
      return {
        data: response.data as T,
        error: null
      };
    } catch (err) {
      const error = err as AxiosErrorResponse;
      console.error(`${TAG}: Insert failed for table ${table}`, error);
      return {
        data: null,
        error: this.parseError(error)
      };
    }
  }

  /**
   * 更新数据
   * @param table 表名
   * @param data 要更新的数据（必须包含主键字段如 id）
   * @param filters 过滤条件（用于定位要更新的记录）
   */
  async update<T>(table: string, data: Object, filters: Object): Promise<SupabaseResult<T>> {
    try {
      // 构建过滤条件
      const filterParams: Record<string, string> = {};
      const filterKeys: string[] = Object.keys(filters);
      filterKeys.forEach(key => {
        const value = (filters as Record<string, Object>)[key];
        filterParams[key] = `eq.${value}`;
      });

      const queryString = Object.keys(filterParams)
        .map(key => `${key}=${filterParams[key]}`)
        .join('&');

      const url = `/${table}?${queryString}`;
      
      // 将过滤字段（如 id）合并到 body 中，确保 PUT upsert 能正确匹配行
      const updateData: Record<string, Object> = {};
      const dataKeys: string[] = Object.keys(data);
      dataKeys.forEach(key => {
        updateData[key] = (data as Record<string, Object>)[key];
      });
      // 将过滤条件也写入 body，保证主键字段存在
      const existingKeys: string[] = Object.keys(updateData);
      filterKeys.forEach(key => {
        if (!existingKeys.includes(key)) {
          updateData[key] = (filters as Record<string, Object>)[key];
        }
      });
      
      console.info(`${TAG}: Update URL: ${url}`);
      console.info(`${TAG}: Update data:`, JSON.stringify(updateData));
      
      // PUT 发送 upsert 请求，body 中包含 id 确保匹配更新而非新增
      const response: AxiosResponse = await this.instance.put(url, updateData);
      
      return {
        data: response.data as T,
        error: null
      };
    } catch (err) {
      const error = err as AxiosErrorResponse;
      console.error(`${TAG}: Update failed for table ${table}`, error);
      console.error(`${TAG}: Error response:`, JSON.stringify(error.response?.data));
      return {
        data: null,
        error: this.parseError(error)
      };
    }
  }

  /**
   * 删除数据
   * @param table 表名
   * @param filters 过滤条件（用于定位要删除的记录）
   */
  async delete(table: string, filters: Object): Promise<SupabaseResult<void>> {
    try {
      // 构建过滤条件
      const filterParams: Record<string, string> = {};
      const filterKeys: string[] = Object.keys(filters);
      filterKeys.forEach(key => {
        const value = (filters as Record<string, Object>)[key];
        filterParams[key] = `eq.${value}`;
      });

      const queryString = Object.keys(filterParams)
        .map(key => `${key}=${filterParams[key]}`)
        .join('&');

      const url = `/${table}?${queryString}`;
      await this.instance.delete(url);
      
      return {
        data: null,
        error: null
      };
    } catch (err) {
      const error = err as AxiosErrorResponse;
      console.error(`${TAG}: Delete failed for table ${table}`, error);
      return {
        data: null,
        error: this.parseError(error)
      };
    }
  }

  /**
   * 执行 RPC 函数
   * @param functionName 函数名
   * @param params 参数
   */
  async rpc<T>(functionName: string, params?: Object): Promise<SupabaseResult<T>> {
    try {
      const response: AxiosResponse = await this.instance.post(`/rpc/${functionName}`, params);
      
      return {
        data: response.data as T,
        error: null
      };
    } catch (err) {
      const error = err as AxiosErrorResponse;
      console.error(`${TAG}: RPC call failed for function ${functionName}`, error);
      return {
        data: null,
        error: this.parseError(error)
      };
    }
  }

  /**
   * 解析错误信息
   */
  private parseError(error: AxiosErrorResponse): SupabaseError {
    if (error.response && error.response.data) {
      const data = error.response.data;
      return {
        message: data.message || error.message || 'Unknown error',
        code: data.code,
        details: data.details,
        hint: data.hint
      };
    }
    
    return {
      message: error.message || 'Unknown error occurred'
    };
  }
}

/**
 * 创建 Supabase 客户端实例
 * @param config Supabase 配置
 */
export function createSupabaseClient(config: SupabaseConfig): SupabaseClient {
  return new SupabaseClient(config);
}
