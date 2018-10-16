import 'package:graph/graph.dart';

void main() {
  final graph = DirectedGraph<String, String>()
    ..addEdge('a', 'b')
    ..addEdge('b', 'c')
    ..addEdge('c', 'a');

  // 3
  print(graph.length);

  // 3
  print(graph.edgeCount);
}
