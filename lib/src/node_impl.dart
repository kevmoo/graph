import 'dart:collection';

import 'package:collection/collection.dart' show UnmodifiableMapView;

import 'node.dart';

class NodeImpl<Key, Data, EdgeData>
    extends UnmodifiableMapView<Key, Set<EdgeData>>
    with Node<Key, Data, EdgeData> {
  final Map<Key, Set<EdgeData>> _map;

  @override
  final Data data;

  NodeImpl._(this.data, this._map) : super(_map);

  factory NodeImpl(Data data, {Iterable<MapEntry<Key, EdgeData>> edges}) {
    final node = NodeImpl._(data, HashMap<Key, Set<EdgeData>>());

    if (edges != null) {
      for (var e in edges) {
        node.addEdge(e.key, e.value);
      }
    }

    return node;
  }

  bool addEdge(Key target, EdgeData data) {
    assert(target != null);
    return _map.putIfAbsent(target, () => HashSet<EdgeData>()).add(data);
  }

  bool removeAllEdgesTo(Key target) => _map.remove(target) != null;

  bool removeEdge(Key target, EdgeData data) {
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
}
