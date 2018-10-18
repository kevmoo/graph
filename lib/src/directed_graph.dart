import 'dart:collection';

import 'package:graphs/graphs.dart' as g;

import 'edge.dart';
import 'node.dart';
import 'pair.dart';

class DirectedGraph<K extends Comparable, E> {
  final Map<K, Node<K, E>> _nodes;

  int get nodeCount => _nodes.length;

  Iterable<K> get nodes => _nodes.keys;

  int get edgeCount =>
      _nodes.values.fold(0, (int v, n) => v + n.outgoingEdges.length);

  DirectedGraph._(this._nodes) {
    assert(
        _nodes.values.every((node) =>
            node.outgoingEdges.every((e) => _nodes.containsKey(e.target))),
        'The source map must contain every node representing edge data.');
  }

  DirectedGraph() : this._(HashMap<K, Node<K, E>>());

  /// ```dart
  /// {
  ///   'a': ['b', {'target': 'b', 'data': 'data'}],
  ///   'b': []
  /// }
  /// ```
  factory DirectedGraph.fromMap(Map<K, List> source) {
    Edge<K, E> edgeFromLiteral(Object source) {
      if (source is Map) {
        return Edge(source['target'] as K, data: source['data'] as E);
      }
      return Edge(source as K);
    }

    // TODO: replace with HashMap.fromEntries - dart-lang/sdk#34818
    final hashMap = HashMap<K, Node<K, E>>()
      ..addEntries(source.entries.map((entry) {
        final edges = (entry.value ?? const []).map(edgeFromLiteral);
        final value = Node<K, E>(entry.key)..outgoingEdges.addAll(edges);
        return MapEntry(entry.key, value);
      }));
    return DirectedGraph._(hashMap);
  }

  bool add(K nodeData) {
    if (nodeData == null) {
      throw ArgumentError.notNull('nodeData');
    }

    final existingCount = nodeCount;
    _nodeFor(nodeData);
    return existingCount < nodeCount;
  }

  bool removeNode(K nodeData) {
    final node = _nodes.remove(nodeData);

    if (node == null) {
      return false;
    }

    // find all edges coming into `node` - and remove them
    for (var otherNode in _nodes.values) {
      assert(otherNode != node);
      assert(otherNode.value != node.value);
      otherNode.outgoingEdges.removeWhere((e) => e.target == node.value);
    }

    return true;
  }

  bool connected(K a, K b) {
    final nodeA = _nodes[a];

    if (nodeA == null) {
      return false;
    }

    return nodeA.edgeTo(b) || _nodes[b].edgeTo(a);
  }

  // TODO: consider caching this!
  Set<Pair<K>> get connectedNodes {
    final pairs = HashSet<Pair<K>>();
    for (var node in _nodes.entries) {
      for (var edge in node.value.outgoingEdges) {
        pairs.add(Pair<K>(node.key, edge.target));
      }
    }
    return pairs;
  }

  bool addEdge(K from, K to, {E edgeData}) {
    if (from == null) {
      throw ArgumentError.notNull('from');
    }
    if (to == null) {
      throw ArgumentError.notNull('to');
    }

    // ensure the `to` node exists
    _nodeFor(to);
    return _nodeFor(from).outgoingEdges.add(Edge(to, data: edgeData));
  }

  bool removeEdge(K from, K to, {E edgeData}) {
    final fromNode = _nodes[from];

    if (fromNode == null) {
      return false;
    }

    return fromNode.outgoingEdges.remove(Edge(to, data: edgeData));
  }

  Node<K, E> _nodeFor(K nodeData) {
    assert(nodeData != null);
    return _nodes.putIfAbsent(nodeData, () => Node(nodeData));
  }

  // TODO: test!
  void clear() {
    _nodes.clear();
  }

  List<List<K>> stronglyConnectedComponents() =>
      g.stronglyConnectedComponents<K, K>(
          nodes, (n) => n, (n) => _nodes[n].outgoingEdges.map((e) => e.target));

  /// ```dart
  /// {
  ///   'a': ['b', {'target': 'b', 'data': 'data'}],
  ///   'b': []
  /// }
  /// ```
  Map<K, List> toMap() => Map.fromEntries(_nodes.entries.map((e) =>
      MapEntry(e.key, e.value.outgoingEdges.map(_edgeLiteralData).toList())));
}

Object _edgeLiteralData(Edge e) {
  if (e.data == null) {
    return e.target;
  }

  return {'target': e.target, 'data': e.data};
}
