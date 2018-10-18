import 'package:graph/graph.dart';

void main() {
  final graph = DirectedGraph<String, String>()
    ..addEdge('a', 'b')
    ..addEdge('b', 'c')
    ..addEdge('c', 'a')
    ..add('d');

  print('Node count: ${graph.nodeCount}');
  // Node count: 4

  print('Edge count: ${graph.edgeCount}');
  // Edge count: 3

  print('toMap: ${graph.toMap()}');
  // toMap: {c: [a], a: [b], b: [c], d: []}

  print('Components: ${graph.stronglyConnectedComponents()}');
  // Components: [[b, a, c], [d]]

  print('Connected pairs: ${graph.connectedNodes}');
  // Connected pairs: {(b, c), (a, b), (a, c)}
}
