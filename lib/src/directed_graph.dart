import 'dart:collection';

import 'package:collection/collection.dart' show UnmodifiableMapView;
import 'package:graphs/graphs.dart' as g;

import 'hash_helper.dart';
import 'node_impl.dart';
import 'pair.dart';

class DirectedGraph<K, E> {
  final Map<K, NodeImpl<K, E>> _nodes;
  final Map<K, Map<K, Set<E>>> mapView;

  final HashHelper<K> _hashHelper;

  int get nodeCount => _nodes.length;

  Iterable<K> get nodes => _nodes.keys;

  int get edgeCount =>
      _nodes.values.expand((n) => n.values).expand((s) => s).length;

  DirectedGraph._(this._nodes, this._hashHelper)
      : mapView = UnmodifiableMapView(_nodes);

  DirectedGraph({
    bool equals(K key1, K key2),
    int hashCode(K key),
  }) : this._(HashMap<K, NodeImpl<K, E>>(hashCode: hashCode, equals: equals),
            HashHelper(equals, hashCode));

  factory DirectedGraph.fromMap(Map<K, Object> source) {
    final graph = DirectedGraph<K, E>();

    MapEntry<K, E> fromMapValue(Object e) {
      if (e is Map &&
          e.length == 2 &&
          e.containsKey('target') &&
          e.containsKey('data')) {
        return MapEntry(e['target'] as K, e['data'] as E);
      }

      return MapEntry(e as K, null);
    }

    for (var entry in source.entries) {
      final entryNode = graph._nodeFor(entry.key);
      final edgeData = entry.value as List ?? const [];

      for (var to in edgeData.map(fromMapValue)) {
        graph._nodeFor(to.key);
        entryNode.addEdge(to.key, to.value);
      }
    }

    return graph;
  }

  bool add(K key) {
    assert(key != null, 'node cannot be null');
    final existingCount = nodeCount;
    _nodeFor(key);
    return existingCount < nodeCount;
  }

  bool removeNode(K key) {
    final node = _nodes.remove(key);

    if (node == null) {
      return false;
    }

    // find all edges coming into `node` - and remove them
    for (var otherNode in _nodes.values) {
      assert(otherNode != node);
      otherNode.removeAllEdgesTo(key);
    }

    return true;
  }

  bool connected(K a, K b) {
    final nodeA = _nodes[a];

    if (nodeA == null) {
      return false;
    }

    return nodeA.containsKey(b) || _nodes[b].containsKey(a);
  }

  bool addEdge(K from, K to, {E edgeData}) {
    assert(from != null, 'from cannot be null');
    assert(to != null, 'to cannot be null');

    // ensure the `to` node exists
    _nodeFor(to);
    return _nodeFor(from).addEdge(to, edgeData);
  }

  bool removeEdge(K from, K to, {E edgeData}) {
    final fromNode = _nodes[from];

    if (fromNode == null) {
      return false;
    }

    return fromNode.removeEdge(to, edgeData);
  }

  // TODO: consider caching this!
  Set<Pair<K>> get connectedNodes {
    final pairs = HashSet<Pair<K>>(
        equals: _hashHelper.pairsEqual, hashCode: _hashHelper.pairHashCode);
    for (var node in _nodes.entries) {
      for (var edge in node.value.keys) {
        pairs.add(Pair<K>(node.key, edge));
      }
    }
    return pairs;
  }

  NodeImpl<K, E> _nodeFor(K nodeKey) {
    assert(nodeKey != null);
    final node = _nodes.putIfAbsent(nodeKey, () => NodeImpl(_hashHelper));
    return node;
  }

  void clear() {
    _nodes.clear();
  }

  /// Returns all of the nodes with edges from [node].
  ///
  /// Throws an [AssertionError] if [node] does not exist.
  Iterable<K> edgesFrom(K node) {
    assert(_nodes.containsKey(node), 'graph does not contain `node`.');
    return _nodes[node].keys;
  }

  List<List<K>> stronglyConnectedComponents() =>
      g.stronglyConnectedComponents<K>(
        nodes,
        edgesFrom,
        equals: _hashHelper.equalsField,
        hashCode: _hashHelper.hashCodeField,
      );

  List<K> shortestPath(K start, K target) {
    assert(_nodes.containsKey(start), 'graph does not contain `start`.');
    assert(_nodes.containsKey(target), 'graph does not contain `target`.');
    return g.shortestPath(
      start,
      target,
      edgesFrom,
      equals: _hashHelper.equalsField,
      hashCode: _hashHelper.hashCodeField,
    );
  }

  Map<K, List<K>> shortestPaths(K start) {
    assert(_nodes.containsKey(start), 'graph does not contain `start`.');
    return g.shortestPaths(
      start,
      edgesFrom,
      equals: _hashHelper.equalsField,
      hashCode: _hashHelper.hashCodeField,
    );
  }

  Map<K, Object> toMap() => Map.fromEntries(_nodes.entries.map(_toMapValue));
}

MapEntry<Key, Object> _toMapValue<Key>(MapEntry<Key, Map<Key, Set>> entry) {
  final nodeEdges = entry.value.entries.expand((e) {
    assert(e.value.isNotEmpty);
    return e.value.map((edgeData) {
      if (edgeData == null) {
        return e.key;
      }
      return {'target': e.key, 'data': edgeData};
    });
  }).toList();

  return MapEntry(entry.key, nodeEdges);
}
