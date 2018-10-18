import 'dart:collection';

import 'package:collection/collection.dart' show UnmodifiableSetView;
import 'package:graphs/graphs.dart' as g;

import 'edge.dart';
import 'node.dart';
import 'pair.dart';

class DirectedGraph<Key extends Comparable, NodeData, EdgeData> {
  final Map<Key, _NodeImpl<Key, NodeData, EdgeData>> _nodes;
  final Map<Key, Node<Key, NodeData, EdgeData>> mapView;

  int get nodeCount => _nodes.length;

  Iterable<Key> get nodes => _nodes.keys;

  int get edgeCount => _nodes.values.fold(0, (int v, n) => v + n.length);

  DirectedGraph._(this._nodes) : mapView = UnmodifiableMapView(_nodes) {
    assert(
        _nodes.values
            .every((node) => node.every((e) => _nodes.containsKey(e.target))),
        'The source map must contain every node representing edge data.');
  }

  DirectedGraph() : this._(HashMap<Key, _NodeImpl<Key, NodeData, EdgeData>>());

  factory DirectedGraph.fromMap(Map<Key, List> source) {
    Edge<Key, EdgeData> edgeFromLiteral(Object source) {
      if (source is Map) {
        return Edge(source['target'] as Key, data: source['data'] as EdgeData);
      }
      return Edge(source as Key);
    }

    // TODO: replace with HashMap.fromEntries - dart-lang/sdk#34818
    final hashMap = HashMap<Key, _NodeImpl<Key, NodeData, EdgeData>>()
      ..addEntries(source.entries.map((entry) {
        final edges = (entry.value ?? const []).map(edgeFromLiteral);
        final value = _NodeImpl<Key, NodeData, EdgeData>(entry.key, null)
          .._data.addAll(edges);
        return MapEntry(entry.key, value);
      }));
    return DirectedGraph._(hashMap);
  }

  bool add(Key key, {NodeData data}) {
    assert(key != null, 'key cannot be null');
    final existingCount = nodeCount;
    _nodeFor(key, data);
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
      assert(otherNode.key != node.key);
      otherNode._data.removeWhere((e) => e.target == node.key);
    }

    return true;
  }

  bool connected(Key a, Key b) {
    final nodeA = _nodes[a];

    if (nodeA == null) {
      return false;
    }

    return nodeA.edgeTo(b) || _nodes[b].edgeTo(a);
  }

  // TODO: consider caching this!
  Set<Pair<Key>> get connectedNodes {
    final pairs = HashSet<Pair<Key>>();
    for (var node in _nodes.entries) {
      for (var edge in node.value) {
        pairs.add(Pair<Key>(node.key, edge.target));
      }
    }
    return pairs;
  }

  bool addEdge(Key from, Key to, {EdgeData edgeData}) {
    assert(from != null, 'from cannot be null');
    assert(to != null, 'to cannot be null');

    // ensure the `to` node exists
    _nodeFor(to, null);
    return _nodeFor(from, null)._data.add(Edge(to, data: edgeData));
  }

  bool removeEdge(Key from, Key to, {EdgeData edgeData}) {
    final fromNode = _nodes[from];

    if (fromNode == null) {
      return false;
    }

    return fromNode._data.remove(Edge(to, data: edgeData));
  }

  _NodeImpl<Key, NodeData, EdgeData> _nodeFor(Key key, NodeData nodeData) {
    assert(key != null);
    final node = _nodes.putIfAbsent(key, () => _NodeImpl(key, nodeData));
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
          nodes, (n) => n, (n) => _nodes[n].map((e) => e.target));

  Map<Key, List> toMap() => Map.fromEntries(_nodes.entries
      .map((e) => MapEntry(e.key, e.value.map(_edgeLiteralData).toList())));
}

Object _edgeLiteralData(Edge e) {
  if (e.data == null) {
    return e.target;
  }

  return {'target': e.target, 'data': e.data};
}

class _NodeImpl<Key, Data, EdgeData>
    extends UnmodifiableSetView<Edge<Key, EdgeData>>
    with Node<Key, Data, EdgeData> {
  @override
  final Key key;

  @override
  final Data data;

  final Set<Edge<Key, EdgeData>> _data;

  _NodeImpl._(this.key, this.data, this._data) : super(_data) {
    assert(key != null, 'key cannot be null');
  }

  factory _NodeImpl(Key key, Data data) =>
      _NodeImpl._(key, data, HashSet<Edge<Key, EdgeData>>());
}
