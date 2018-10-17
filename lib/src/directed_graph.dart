import 'dart:collection';

import 'edge.dart';
import 'node.dart';
import 'pair.dart';

class DirectedGraph<N extends Comparable, E> {
  final Map<N, Node<N, E>> _nodes;

  int get nodeCount => _nodes.length;

  Iterable<N> get nodes => _nodes.keys;

  int get edgeCount =>
      _nodes.values.fold(0, (int v, n) => v + n.outgoingEdges.length);

  DirectedGraph._(this._nodes) {
    assert(
        _nodes.values.every((node) =>
            node.outgoingEdges.every((e) => _nodes.containsKey(e.target))),
        'The source map must contain every node representing edge data.');
  }

  DirectedGraph() : this._(HashMap<N, Node<N, E>>());

  factory DirectedGraph.fromJson(Map<String, dynamic> json,
      {N Function(String) nodeConvert}) {
    nodeConvert ??= (String value) => value as N;

    // TODO: replace with HashMap.fromEntries - dart-lang/sdk#34818
    final hashMap = HashMap<N, Node<N, E>>()
      ..addEntries(json.entries.map((entry) {
        final key = nodeConvert(entry.key);
        final edges = (entry.value as List)
            .map((v) => Edge<N, E>.fromJson(v, nodeConvert: nodeConvert));
        final value = Node<N, E>(nodeConvert(entry.key))
          ..outgoingEdges.addAll(edges);
        return MapEntry(key, value);
      }));
    return DirectedGraph._(hashMap);
  }

  bool add(N nodeData) {
    if (nodeData == null) {
      throw ArgumentError.notNull('nodeData');
    }

    final existingCount = nodeCount;
    _nodeFor(nodeData);
    return existingCount < nodeCount;
  }

  bool removeNode(N nodeData) {
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

  bool connected(N a, N b) {
    final nodeA = _nodes[a];

    if (nodeA == null) {
      return false;
    }

    return nodeA.edgeTo(b) || _nodes[b].edgeTo(a);
  }

  // TODO: consider caching this!
  Set<Pair<N>> get connectedNodes {
    final pairs = HashSet<Pair<N>>();
    for (var node in _nodes.entries) {
      for (var edge in node.value.outgoingEdges) {
        pairs.add(Pair<N>(node.key, edge.target));
      }
    }
    return pairs;
  }

  bool addEdge(N from, N to, {E edgeData}) {
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

  bool removeEdge(N from, N to, {E edgeData}) {
    final fromNode = _nodes[from];

    if (fromNode == null) {
      return false;
    }

    return fromNode.outgoingEdges.remove(Edge(to, data: edgeData));
  }

  Node<N, E> _nodeFor(N nodeData) {
    assert(nodeData != null);
    return _nodes.putIfAbsent(nodeData, () => Node(nodeData));
  }

  // TODO: test!
  void clear() {
    _nodes.clear();
  }

  /// Returns a [Map] representing a valid JSON value of `this`.
  ///
  /// Note: the node/key type [N] is converted to a [String] by calling
  /// `toString`. To create a valid [Map], the `toString` on each key must be
  /// unique for each node in the map.
  Map<String, List> toJson() => Map.fromEntries(_nodes.entries.map((e) {
        return MapEntry(e.key.toString(), e.value.outgoingEdges.toList());
      }));
}
