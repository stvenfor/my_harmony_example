/**
 * 基于 @ohos/axios 的全局单例 HTTP 封装。
 * - 默认 baseURL 指向玩 Android 开放 API（https://www.wanandroid.com/），与 {@link https://www.wanandroid.com/ } 站点约定一致
 * - HTTP 2xx 响应体若含 errorCode / errorMsg / data，按 ResBasicModel 映射为 ApiResult；否则整包作为 data 透出
 * - 首次请求内完成单例与 pura Loading 绑定；多请求共用一个 Loading
 */

import { common } from '@kit.AbilityKit';
import { ResBasicModel } from '../model/ResBasicModel';
import axios, {
  AxiosError,
  AxiosHeaders,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig,
  isAxiosError,
  RawAxiosRequestHeaders
} from '@ohos/axios';
import { DialogHelper } from '@pura/harmony-dialog';
import { getApiBaseUrl, getAppEnvBundle } from '../constants/AppEnvironment';

/** 统一响应壳；玩 Android 接口时 code/message 对应 errorCode/errorMsg */
export interface ApiResult<T> {
  code: number;
  message: string;
  data?: T;
}

/**
 * 玩 Android 默认网关（开放 API），见 https://www.wanandroid.com/
 * 多环境下若未配置 API_BASE_URL，则 {@link getApiBaseUrl} 会退回此地址。
 */
export const WAN_ANDROID_BASE_URL: string = 'https://www.wanandroid.com/';

/** 创建独立客户端时的配置 */
export interface IsolatedHttpClientOptions {
  baseURL?: string;
  timeout?: number;
  /** 与单次请求的 headers 合并，单次请求优先 */
  defaultHeaders?: Record<string, string>;
  /** HTTP 成功时写入 ApiResult.code，默认 0 */
  successCode?: number;
  /** HTTP 401 时触发（如跳转登录），由宿主注入，保持可移植 */
  onUnauthorized?: () => void;
  /** HTTP 403 时触发（如无权限页） */
  onForbidden?: () => void;
  /** 响应阶段错误（含 HTTP 4xx/5xx 与网络错误） */
  onResponseError?: (error: AxiosError<Object>) => void;
  /** 在合并 Header 之后执行，可追加 Token 等 */
  augmentRequest?: (config: InternalAxiosRequestConfig) =>
    InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>;
}

/** 单次 get/post 的可选配置 */
export interface HttpRequestOptions {
  /** 本次请求基地址（覆盖单例默认 baseURL），便于各模块指向不同网关 */
  baseURL?: string;
  /** 与全局 defaultHeaders 及内置默认头合并，本次优先 */
  headers?: Record<string, string>;
  /** true 时参与全局 Loading 引用计数（多并发仍只显示一个遮罩） */
  showLoading?: boolean;
  /** 透传 axios，与 headers / baseURL 已在封装内合并 */
  axiosConfig?: AxiosRequestConfig<Object>;
}

/** pura Loading 弹窗 id，与引用计数配合仅保留一个实例 */
let gPuraLoadingDialogId: string | undefined = undefined;
let gHttpLoadingRefCount: number = 0;
/** 是否已向 DialogHelper 注入 UIAbilityContext（失败时下次请求重试） */
let gPuraDialogContextBound: boolean = false;

/** 全应用唯一 HTTP 客户端 */
let gHttpClientSingleton: IsolatedHttpClient | null = null;

/** 单例默认：baseURL / 超时来自编译期环境（BuildProfile），未配置 API_BASE_URL 时退回玩 Android */
const INTERNAL_HTTP_SINGLETON_OPTIONS: IsolatedHttpClientOptions = {
  baseURL: getApiBaseUrl(),
  timeout: getAppEnvBundle().connectTimeoutMs,
  successCode: 0
};

/**
 * 绑定 harmony-dialog 所需的 UIAbilityContext，避免业务在 Ability 里手写初始化。
 */
function tryBindPuraDialogContext(): void {
  if (gPuraDialogContextBound) {
    return;
  }
  try {
    const ctx: common.UIAbilityContext = getContext() as common.UIAbilityContext;
    DialogHelper.setDefaultConfig((c) => {
      c.uiAbilityContext = ctx;
    });
    gPuraDialogContextBound = true;
  } catch (_e) {
    // 尚无 UI 上下文（如过早调用），下次请求再试
  }
}

function ensureHttpSingletonClient(): void {
  if (gHttpClientSingleton !== null) {
    return;
  }
  gHttpClientSingleton = new IsolatedHttpClient(INTERNAL_HTTP_SINGLETON_OPTIONS);
}

/**
 * 强制关闭 Loading 并清零计数（切账号等）。
 */
export function resetHttpLoadingState(): void {
  if (gPuraLoadingDialogId !== undefined && gPuraLoadingDialogId.length > 0) {
    try {
      DialogHelper.closeDialog(gPuraLoadingDialogId);
    } catch (_e) {
      // ignore
    }
    gPuraLoadingDialogId = undefined;
  }
  gHttpLoadingRefCount = 0;
}

function httpLoadingAcquire(): void {
  tryBindPuraDialogContext();
  if (gHttpLoadingRefCount === 0) {
    try {
      if (gPuraLoadingDialogId !== undefined && gPuraLoadingDialogId.length > 0) {
        DialogHelper.closeDialog(gPuraLoadingDialogId);
        gPuraLoadingDialogId = undefined;
      }
      gPuraLoadingDialogId = DialogHelper.showLoadingDialog({
        content: '加载中…',
        autoCancel: false,
        backCancel: false,
        isModal: true
      });
    } catch (_e) {
      gPuraLoadingDialogId = undefined;
      return;
    }
  }
  gHttpLoadingRefCount++;
}

function httpLoadingRelease(): void {
  if (gHttpLoadingRefCount > 0) {
    gHttpLoadingRefCount--;
  }
  if (gHttpLoadingRefCount === 0) {
    if (gPuraLoadingDialogId !== undefined && gPuraLoadingDialogId.length > 0) {
      try {
        DialogHelper.closeDialog(gPuraLoadingDialogId);
      } catch (_e) {
        // ignore
      }
      gPuraLoadingDialogId = undefined;
    }
  }
}

/**
 * 获取单例；首次调用时内部创建 axios 客户端并尝试绑定弹窗上下文。
 */
export function getHttpClient(): IsolatedHttpClient {
  ensureHttpSingletonClient();
  return gHttpClientSingleton as IsolatedHttpClient;
}

/**
 * GET：Promise 始终 resolve 为 ApiResult（网络/HTTP 错误也写入 code/message），不向业务抛 reject。
 */
export function httpGet<T>(
  url: string,
  params?: Record<string, Object>,
  options?: HttpRequestOptions
): Promise<ApiResult<T>> {
  return getHttpClient().get<T>(url, params, options);
}

/** POST：同 httpGet，始终 resolve ApiResult */
export function httpPost<T>(
  url: string,
  body?: Object,
  options?: HttpRequestOptions
): Promise<ApiResult<T>> {
  return getHttpClient().post<T>(url, body, options);
}

const BUILTIN_DEFAULT_HEADERS: Record<string, string> = {
  'Content-Type': 'application/json;charset=UTF-8',
  'Accept': 'application/json'
};

function cloneStringRecord(source: Record<string, string>): Record<string, string> {
  const result: Record<string, string> = {};
  const keys: string[] = Object.keys(source);
  for (let i = 0; i < keys.length; i++) {
    const k: string = keys[i];
    result[k] = source[k];
  }
  return result;
}

function mergeStringRecords(
  base: Record<string, string>,
  override?: Record<string, string>
): Record<string, string> {
  const out: Record<string, string> = cloneStringRecord(base);
  if (!override) {
    return out;
  }
  const keys2: string[] = Object.keys(override);
  for (let j = 0; j < keys2.length; j++) {
    const k2: string = keys2[j];
    out[k2] = override[k2];
  }
  return out;
}

function applyMergedHeaders(
  config: InternalAxiosRequestConfig,
  merged: Record<string, string>
): InternalAxiosRequestConfig {
  const headers: AxiosHeaders = AxiosHeaders.from(merged as RawAxiosRequestHeaders);
  config.headers = headers;
  return config;
}

/**
 * 若响应体为玩 Android ResBasicModel 结构则解析，否则返回 null。
 */
function tryParseResBasicEnvelope<T>(body: Object | undefined): ApiResult<T> | null {
  if (body === undefined || body === null) {
    return null;
  }
  if (typeof body !== 'object') {
    return null;
  }
  const rec: Record<string, Object> = body as Record<string, Object>;
  if (rec['errorCode'] === undefined) {
    return null;
  }
  const ecRaw: Object | undefined = rec['errorCode'];
  const emRaw: Object | undefined = rec['errorMsg'];
  const dataVal: Object | undefined = rec['data'];
  const ec: number = typeof ecRaw === 'number' ? ecRaw : -1;
  const em: string = typeof emRaw === 'string' ? emRaw : '';
  const model: ResBasicModel<T> = new ResBasicModel<T>(ec, em, dataVal as T);
  return {
    code: model.errorCode,
    message: model.errorMsg,
    data: model.data
  };
}

function extractStatusMessage(ax: AxiosError<Object>): string {
  const fromBody: Object | undefined = ax.response?.data;
  if (fromBody !== undefined && fromBody !== null) {
    const body: Record<string, Object> = fromBody as Record<string, Object>;
    const errMsg: Object | undefined = body['errorMsg'];
    if (typeof errMsg === 'string' && errMsg.length > 0) {
      return errMsg;
    }
    const msgVal: Object | undefined = body['message'] ?? body['msg'] ?? body['error'];
    if (typeof msgVal === 'string' && msgVal.length > 0) {
      return msgVal;
    }
  }
  if (ax.response?.statusText && ax.response.statusText.length > 0) {
    return ax.response.statusText;
  }
  return ax.message.length > 0 ? ax.message : 'request failed';
}

function failureFromUnknown<T>(err: Object): ApiResult<T> {
  const e: Error = err as Error;
  return {
    code: -1,
    message: e?.message ?? 'unknown error',
    data: undefined
  };
}

function failureFromAxios<T>(ax: AxiosError<Object>): ApiResult<T> {
  const payload: Object | undefined = ax.response?.data;
  const parsed: ApiResult<T> | null = tryParseResBasicEnvelope<T>(payload);
  if (parsed !== null) {
    return parsed;
  }
  const status: number = ax.response?.status ?? -1;
  return {
    code: status,
    message: extractStatusMessage(ax),
    data: payload as T
  };
}

/**
 * 独立 HTTP 客户端：内部持有一个 AxiosInstance，拦截器仅作用于本实例。
 */
export class IsolatedHttpClient {
  private readonly instance: AxiosInstance;
  private readonly successCode: number;
  private readonly defaultHeaders: Record<string, string>;
  private readonly options: IsolatedHttpClientOptions;

  constructor(options: IsolatedHttpClientOptions) {
    this.options = options;
    this.successCode = options.successCode ?? 0;
    this.defaultHeaders = mergeStringRecords(BUILTIN_DEFAULT_HEADERS, options.defaultHeaders ?? {});

    this.instance = axios.create({
      baseURL: options.baseURL,
      timeout: options.timeout ?? 30000,
      headers: cloneStringRecord(this.defaultHeaders)
    });

    this.instance.interceptors.request.use(
      async (config: InternalAxiosRequestConfig): Promise<InternalAxiosRequestConfig> => {
        const perRequest: Record<string, string> | undefined =
          IsolatedHttpClient.headersToRecord(config.headers);
        const merged: Record<string, string> = mergeStringRecords(this.defaultHeaders, perRequest);
        let next: InternalAxiosRequestConfig = applyMergedHeaders(config, merged);
        if (this.options.augmentRequest) {
          next = await this.options.augmentRequest(next);
        }
        return next;
      },
      (error: Object) => {
        return Promise.reject(error);
      }
    );

    this.instance.interceptors.response.use(
      (response: AxiosResponse): AxiosResponse => {
        return response;
      },
      (error: Object) => {
        if (isAxiosError(error)) {
          const ax: AxiosError<Object> = error as AxiosError<Object>;
          const st: number | undefined = ax.response?.status;
          if (st === 401) {
            this.options.onUnauthorized?.();
          } else if (st === 403) {
            this.options.onForbidden?.();
          }
          this.options.onResponseError?.(ax);
        }
        return Promise.reject(error);
      }
    );
  }

  /**
   * 将 AxiosHeaders / 普通对象转为 Record，便于与默认头合并。
   */
  private static headersToRecord(raw: Object | undefined): Record<string, string> | undefined {
    if (raw === undefined || raw === null) {
      return undefined;
    }
    if (raw instanceof AxiosHeaders) {
      const jsonObj: Object = raw.toJSON(true) as Object;
      const rec: Record<string, Object> = jsonObj as Record<string, Object>;
      const out: Record<string, string> = {};
      const keys: string[] = Object.keys(rec);
      for (let i = 0; i < keys.length; i++) {
        const key: string = keys[i];
        const val: Object = rec[key];
        if (typeof val === 'string') {
          out[key] = val;
        } else if (Array.isArray(val)) {
          out[key] = (val as string[]).join(',');
        } else if (val !== undefined && val !== null) {
          out[key] = String(val);
        }
      }
      return out;
    }
    const plain: Record<string, Object> = raw as Record<string, Object>;
    const out2: Record<string, string> = {};
    const keys2: string[] = Object.keys(plain);
    for (let j = 0; j < keys2.length; j++) {
      const k2: string = keys2[j];
      const v2: Object = plain[k2];
      if (typeof v2 === 'string') {
        out2[k2] = v2;
      }
    }
    return out2;
  }

  /**
   * 追加请求拦截器（仅本实例），返回 id 可用于 eject。
   */
  addRequestInterceptor(
    onFulfilled: (config: InternalAxiosRequestConfig) =>
      InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>,
    onRejected?: (error: Object) => Object | Promise<Object>
  ): number {
    return this.instance.interceptors.request.use(onFulfilled, onRejected);
  }

  /**
   * 追加响应拦截器（仅本实例）。
   */
  addResponseInterceptor(
    onFulfilled: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>,
    onRejected?: (error: Object) => Object | Promise<Object>
  ): number {
    return this.instance.interceptors.response.use(onFulfilled, onRejected);
  }

  ejectRequestInterceptor(id: number): void {
    this.instance.interceptors.request.eject(id);
  }

  ejectResponseInterceptor(id: number): void {
    this.instance.interceptors.response.eject(id);
  }

  /**
   * 暴露底层实例供极少数场景使用；常规业务请优先 get/post。
   */
  getAxiosInstance(): AxiosInstance {
    return this.instance;
  }

  /**
   * GET：params 为查询串；options 中可配 headers、showLoading、axiosConfig（含 params 时仅当未传 params 形参生效）。
   */
  async get<T>(
    url: string,
    params?: Record<string, Object>,
    options?: HttpRequestOptions
  ): Promise<ApiResult<T>> {
    const showLoading: boolean = options?.showLoading === true;
    return IsolatedHttpClient.runWithOptionalLoading<T>(showLoading, async (): Promise<ApiResult<T>> => {
      const mergedConfig: AxiosRequestConfig =
        IsolatedHttpClient.buildMergedAxiosConfigForGet(options, params);
      try {
        const res: AxiosResponse<Object> =
          await this.instance.get<Object, AxiosResponse<Object>, null>(url, mergedConfig);
        return IsolatedHttpClient.mapSuccessBodyToApiResult<T>(res.data, this.successCode);
      } catch (err) {
        return IsolatedHttpClient.toApiResult<T>(err);
      }
    });
  }

  /**
   * POST：body 为请求体；options 可配 headers、showLoading、axiosConfig。
   */
  async post<T>(
    url: string,
    body?: Object,
    options?: HttpRequestOptions
  ): Promise<ApiResult<T>> {
    const showLoading: boolean = options?.showLoading === true;
    return IsolatedHttpClient.runWithOptionalLoading<T>(showLoading, async (): Promise<ApiResult<T>> => {
      const mergedConfig: AxiosRequestConfig<Object> =
        IsolatedHttpClient.buildMergedAxiosConfigForPost(options);
      try {
        const res: AxiosResponse<Object> =
          await this.instance.post<Object, AxiosResponse<Object>, Object>(url, body, mergedConfig);
        return IsolatedHttpClient.mapSuccessBodyToApiResult<T>(res.data, this.successCode);
      } catch (err) {
        return IsolatedHttpClient.toApiResult<T>(err);
      }
    });
  }

  /**
   * showLoading 时：acquire → 执行 → finally 中必定 release，避免漏关。
   */
  private static async runWithOptionalLoading<T>(
    showLoading: boolean,
    task: () => Promise<ApiResult<T>>
  ): Promise<ApiResult<T>> {
    if (showLoading) {
      httpLoadingAcquire();
    }
    try {
      return await task();
    } finally {
      if (showLoading) {
        httpLoadingRelease();
      }
    }
  }

  private static buildMergedAxiosConfigForGet(
    options: HttpRequestOptions | undefined,
    params: Record<string, Object> | undefined
  ): AxiosRequestConfig {
    const base: AxiosRequestConfig<Object> = options?.axiosConfig ? options.axiosConfig : {};
    const cfg: AxiosRequestConfig<Object> = IsolatedHttpClient.withExtraHeaders(base, options?.headers);
    if (params !== undefined) {
      cfg.params = params;
    }
    IsolatedHttpClient.applyRequestBaseURL(cfg, options);
    return cfg;
  }

  private static buildMergedAxiosConfigForPost(
    options: HttpRequestOptions | undefined
  ): AxiosRequestConfig<Object> {
    const base: AxiosRequestConfig<Object> = options?.axiosConfig ? options.axiosConfig : {};
    const cfg: AxiosRequestConfig<Object> = IsolatedHttpClient.withExtraHeaders(base, options?.headers);
    IsolatedHttpClient.applyRequestBaseURL(cfg, options);
    return cfg;
  }

  /** options.baseURL 优先于 axiosConfig.baseURL */
  private static applyRequestBaseURL(
    cfg: AxiosRequestConfig<Object>,
    options: HttpRequestOptions | undefined
  ): void {
    if (options?.baseURL !== undefined && options.baseURL.length > 0) {
      cfg.baseURL = options.baseURL;
    }
  }

  private static withExtraHeaders(
    extraConfig: AxiosRequestConfig<Object> | undefined,
    extraHeaders: Record<string, string> | undefined
  ): AxiosRequestConfig<Object> {
    const base: AxiosRequestConfig<Object> = extraConfig ? extraConfig : {};
    if (!extraHeaders) {
      return base;
    }
    const prev: Record<string, string> | undefined = IsolatedHttpClient.headersToRecord(
      base.headers as Object | undefined
    );
    const merged: Record<string, string> = mergeStringRecords(prev ?? {}, extraHeaders);
    base.headers = AxiosHeaders.from(merged as RawAxiosRequestHeaders);
    return base;
  }

  private static toApiResult<T>(err: Object): ApiResult<T> {
    if (isAxiosError(err)) {
      return failureFromAxios(err as AxiosError<Object>);
    }
    return failureFromUnknown(err);
  }

  /** HTTP 成功：优先按玩 Android ResBasicModel 解析，否则整包作为 data */
  private static mapSuccessBodyToApiResult<T>(body: Object | undefined, defaultSuccessCode: number): ApiResult<T> {
    const parsed: ApiResult<T> | null = tryParseResBasicEnvelope<T>(body);
    if (parsed !== null) {
      return parsed;
    }
    return {
      code: defaultSuccessCode,
      message: 'OK',
      data: body as T
    };
  }
}
