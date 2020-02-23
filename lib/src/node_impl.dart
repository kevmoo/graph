import 'dart:collection';

import 'hash_helper.dart';

class NodeImpl<K, E> extends UnmodifiableMapBase<K, Set<E>> {
  final Map<K, Set<E>> _map;

  NodeImpl._(this._map);

  factory NodeImpl(HashHelper<K> hashHelper, {Iterable<MapEntry<K, E>> edges}) {
    final node = NodeImpl._(
      HashMap<K, Set<E>>(
        equals: hashHelper.equalsField,
        hashCode: hashHelper.hashCodeField,
      ),
    );

    if (edges != null) {
      for (var e in edges) {
        node.addEdge(e.key, e.value);
      }
    }

    return node;
  }

  bool addEdge(K target, E data) {
    assert(target != null);
    return _map.putIfAbsent(target, _createSet).add(data);
  }

  Set<E> _createSet() => HashSet<E>();

  bool removeAllEdgesTo(K target) => _map.remove(target) != null;

  bool removeEdge(K target, E data) {
    assert(target != null);

    final set = _map[target];
    if (set == null) {
      return false;
    }
    try {
      return set.remove(data);
    } finally {
      if (set.isEmpty) {
        _map.remove(target);
      }
      assert(!_map.containsKey(target) || _map[target].isNotEmpty);
    }
  }

  @override
  Set<E> operator [](Object key) => _map[key];

  @override
  Iterable<K> get keys => _map.keys;
}
