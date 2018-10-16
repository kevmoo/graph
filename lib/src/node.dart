import 'dart:collection';

import 'edge.dart';

class Node<N, E> {
  final N value;
  final outgoingEdges = HashSet<Edge<N, E>>();

  Node(this.value);

  bool edgeTo(N other) => outgoingEdges.any((e) => e.target == other);
}
