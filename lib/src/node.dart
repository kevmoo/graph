import 'dart:collection';

import 'edge.dart';

class Node<K, E> {
  final K value;
  final outgoingEdges = HashSet<Edge<K, E>>();

  Node(this.value);

  bool edgeTo(K other) => outgoingEdges.any((e) => e.target == other);
}
