import 'dart:collection';

class DirectedGraph<N, E> extends MapBase<N, Set<Edge<N, E>>> {
  final Map<N, _Node<N, E>> _nodes;

  @override
  int get length => _nodes.length;

  @override
  Iterable<N> get keys => _nodes.keys;

  int get edgeCount =>
      _nodes.values.fold(0, (int v, n) => v + n.outgoingEdges.length);

  DirectedGraph._(this._nodes) {
    assert(
        _nodes.values.every((node) =>
            node.outgoingEdges.every((e) => _nodes.containsKey(e.target))),
        'The source map must contain every node represented edge data.');
  }

  DirectedGraph() : this._(HashMap<N, _Node<N, E>>());

  factory DirectedGraph.fromJson(Map<String, dynamic> json,
      {N Function(String) nodeConvert}) {
    nodeConvert ??= (String value) => value as N;

    return DirectedGraph._(HashMap.fromIterable(json.entries, key: (entry) {
      return nodeConvert((entry as MapEntry<String, dynamic>).key);
    }, value: (entry) {
      final e = (entry as MapEntry<String, dynamic>);
      return _Node._(nodeConvert(e.key))
        ..outgoingEdges.addAll((e.value as List).map((v) => Edge.fromJson(
            v as Map<String, dynamic>,
            nodeConvert: nodeConvert)));
    }));
  }

  bool add(N nodeData) {
    if (nodeData == null) {
      throw ArgumentError.notNull('nodeData');
    }

    final existingCount = length;
    _nodeFor(nodeData);
    return existingCount < length;
  }

  bool removeNode(N nodeData) => remove(nodeData) != null;

  @override
  Set<Edge<N, E>> remove(Object key) {
    final node = _nodes.remove(key);

    if (node == null) {
      return null;
    }

    // find all edges coming into `node` - and remove them
    for (var otherNode in _nodes.values) {
      assert(otherNode != node);
      assert(otherNode.value != node.value);
      otherNode.outgoingEdges.removeWhere((e) => e.target == node.value);
    }

    return node.outgoingEdges;
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

  _Node<N, E> _nodeFor(N nodeData) {
    assert(nodeData != null);
    return _nodes.putIfAbsent(nodeData, () => _Node._(nodeData));
  }

  @override
  Set<Edge<N, E>> operator [](Object key) => _nodes[key]?.outgoingEdges;

  /// Creates or updates a node with value [key].
  ///
  /// If [key] already exists, [value] will replace all existing edges.
  ///
  /// If [value] is `null`, it will be treated as empty.
  @override
  void operator []=(N key, Set<Edge<N, E>> value) {
    final node = _nodeFor(key);
    node.outgoingEdges.clear();
    node.outgoingEdges.addAll(value ?? []);
  }

  @override
  void clear() {
    _nodes.clear();
  }

  /// Returns a [Map] representing a valid JSON value of `this`.
  ///
  /// Note: the node/key type [N] is converted to a [String] by calling
  /// `toString`. To create a valid [Map], the `toString` on each key must be
  /// unique for each node in the map.
  ///
  ///
  Map<String, List> toJson() => Map.fromEntries(entries.map((e) {
        return MapEntry(e.key.toString(), e.value.toList());
      }));
}

class _Node<N, E> {
  final N value;
  final outgoingEdges = HashSet<Edge<N, E>>();

  _Node._(this.value);
}

class Edge<N, D> {
  final N target;
  final D data;

  Edge(this.target, {this.data});

  factory Edge.fromJson(Map<String, dynamic> json,
      {N Function(String) nodeConvert}) {
    nodeConvert ??= (String value) => value as N;

    return Edge(nodeConvert(json['target'] as String), data: json['data'] as D);
  }

  @override
  bool operator ==(Object other) =>
      other is Edge && other.target == target && other.data == data;

  @override
  int get hashCode => target.hashCode * 31 + data.hashCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'target': target.toString()};
    if (data != null) {
      map['data'] = data;
    }
    return map;
  }
}
