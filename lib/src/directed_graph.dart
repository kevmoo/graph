import 'dart:collection';

import 'package:collection/collection.dart' show UnmodifiableMapView;
import 'package:graphs/graphs.dart' as g;

import 'node.dart';
import 'node_impl.dart';
import 'pair.dart';

class DirectedGraph<Key extends Comparable, NodeData, EdgeData> {
  final Map<Key, NodeImpl<Key, NodeData, EdgeData>> _nodes;
  final Map<Key, Node<Key, NodeData, EdgeData>> mapView;

  int get nodeCount => _nodes.length;

  Iterable<Key> get nodes => _nodes.keys;

  int get edgeCount =>
      _nodes.values.expand((n) => n.values).expand((s) => s).length;

  DirectedGraph._(this._nodes) : mapView = UnmodifiableMapView(_nodes) {
    assert(_nodes.values.every((node) => node.keys.every(_nodes.containsKey)),
        'The source map must contain every node representing edge data.');
  }

  DirectedGraph() : this._(HashMap<Key, NodeImpl<Key, NodeData, EdgeData>>());

  factory DirectedGraph.fromMap(Map<Key, Object> source) {
    // TODO: replace with HashMap.fromEntries - dart-lang/sdk#34818
    final hashMap = HashMap<Key, NodeImpl<Key, NodeData, EdgeData>>()
      ..addEntries(
          source.entries.map((e) => _fromMapValue<Key, NodeData, EdgeData>(e)));
    return DirectedGraph._(hashMap);
  }

  bool add(Key node, {NodeData data}) {
    assert(node != null, 'node cannot be null');
    final existingCount = nodeCount;
    _nodeFor(node, data);
    return existingCount < nodeCount;
  }

  bool removeNode(Key nodeData) {
    final node = _nodes.remove(nodeData);

    if (node == null) {
      return false;
    }

    // find all edges coming into `node` - and remove them
    for (var otherNode in _nodes.values) {
      assert(otherNode != node);
      otherNode.removeAllEdgesTo(nodeData);
    }

    return true;
  }

  bool connected(Key a, Key b) {
    final nodeA = _nodes[a];

    if (nodeA == null) {
      return false;
    }

    return nodeA.containsKey(b) || _nodes[b].containsKey(a);
  }

// TODO: consider caching this!
  Set<Pair<Key>> get connectedNodes {
    final pairs = HashSet<Pair<Key>>();
    for (var node in _nodes.entries) {
      for (var edge in node.value.keys) {
        pairs.add(Pair<Key>(node.key, edge));
      }
    }
    return pairs;
  }

  bool addEdge(Key from, Key to, {EdgeData edgeData}) {
    assert(from != null, 'from cannot be null');
    assert(to != null, 'to cannot be null');

    // ensure the `to` node exists
    _nodeFor(to, null);
    return _nodeFor(from, null).addEdge(to, edgeData);
  }

  bool removeEdge(Key from, Key to, {EdgeData edgeData}) {
    final fromNode = _nodes[from];

    if (fromNode == null) {
      return false;
    }

    return fromNode.removeEdge(to, edgeData);
  }

  NodeImpl<Key, NodeData, EdgeData> _nodeFor(Key nodeKey, NodeData nodeData) {
    assert(nodeKey != null);
    final node = _nodes.putIfAbsent(nodeKey, () => NodeImpl(nodeData));
    assert(
        nodeData == null || identical(nodeData, node.data),
        'If nodeData is provided and the node exists, '
        'it must be identical to the stored data.');
    return node;
  }

// TODO: test!
  void clear() {
    _nodes.clear();
  }

  List<List<Key>> stronglyConnectedComponents() =>
      g.stronglyConnectedComponents<Key, Key>(
          nodes, (n) => n, (n) => _nodes[n].keys);

  Map<Key, Object> toMap() => Map.fromEntries(_nodes.entries.map(_toMapValue));
}

MapEntry<Key, NodeImpl<Key, NodeData, EdgeData>>
    _fromMapValue<Key, NodeData, EdgeData>(MapEntry<Key, Object> source) {
  final sourceValue = source.value;
  NodeData data;
  List edgeData;

  if (sourceValue is Map) {
    data = sourceValue['data'] as NodeData;
    edgeData = sourceValue['edges'] as List;
  } else {
    edgeData = sourceValue as List ?? const [];
  }

  return MapEntry(
      source.key,
      NodeImpl<Key, NodeData, EdgeData>(data, edges: edgeData.map((e) {
        if (e is Map) {
          return MapEntry(e['target'] as Key, e['data'] as EdgeData);
        }

        return MapEntry(e as Key, null);
      })));
}

MapEntry<Key, Object> _toMapValue<Key>(
    MapEntry<Key, Node<Key, dynamic, dynamic>> entry) {
  final nodeEdges = entry.value.entries.expand((e) {
    assert(e.value.isNotEmpty);
    return e.value.map((edgeData) {
      if (edgeData == null) {
        return e.key;
      }
      return {'target': e.key, 'data': edgeData};
    });
  }).toList();

  final value = entry.value.data == null
      ? nodeEdges
      : {'data': entry.value.data, 'edges': nodeEdges};
  return MapEntry(entry.key, value);
}
