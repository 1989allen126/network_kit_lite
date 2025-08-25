/// 缓存策略枚举
enum CachePolicy {
  /// 仅从网络获取数据，不使用缓存
  networkOnly,

  /// 先使用缓存数据，同时在后台更新缓存
  cacheAndNetwork,

  /// 优先使用缓存数据，如果缓存不存在则请求网络
  cacheFirst,

  /// 只使用缓存数据，不请求网络
  cacheOnly,

  /// 先请求网络，成功后更新缓存
  networkFirst,
}
