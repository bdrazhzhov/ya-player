import 'dart:async';

typedef EventHandler<T> = Future<void> Function(T args);

class Event<T> {
  late final List<EventHandler<T>> _handlers = [];

  void addHandler(EventHandler<T> handler) {
    _handlers.add(handler);
  }

  bool removeHandler(EventHandler<T> handler) {
    return _handlers.remove(handler);
  }

  void clearHandlers() {
    _handlers.clear();
  }

  Future<void> emit(T args) async {
    if (_handlers.isEmpty) return;

    for (var i = 0; i < _handlers.length; i++) {
      await _handlers[i](args);
    }
  }
}

class EventProxy<T> {
  final Event<T> _event;

  EventProxy(this._event);

  void addHandler(EventHandler<T> handler) => _event.addHandler(handler);
  bool removeHandler(EventHandler<T> handler) => _event.removeHandler(handler);
}
