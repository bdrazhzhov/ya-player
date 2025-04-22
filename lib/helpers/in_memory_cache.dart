class InMemoryCache {
  final Map<String, _CacheItem> _cache = {};

  void set(String key, dynamic value, {Duration? expiration}) {
    DateTime? expiresAt;
    if(expiration != null) {
      expiresAt = DateTime.now().add(expiration);
    }
    _cache[key] = _CacheItem(value, expiresAt: expiresAt);
  }

  Map<String, dynamic>? get(String key) {
    final value = _cache[key];

    if(value?.expiresAt?.isBefore(DateTime.now()) == true) {
      _cache.remove(key);
      return null;
    }

    return value?.object;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}

class _CacheItem {
  final dynamic object;
  final DateTime? expiresAt;

  _CacheItem(this.object, {this.expiresAt});
}
