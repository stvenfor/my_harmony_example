/** 分页列表容器状态 */
export enum PaginatedListStatus {
  Idle = 0,
  InitialLoading = 1,
  Refreshing = 2,
  LoadingMore = 3,
  Empty = 4,
  NoMore = 5,
  Error = 6
}

/** 业务 onRefresh / onLoadMore 返回值（数据由业务写入 @Link items） */
export interface PaginatedListResult {
  hasMore: boolean
}
