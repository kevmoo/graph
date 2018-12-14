import 'package:graph/graph.dart';
import 'package:test/test.dart';

void main() {
  test('strongly connected components', () {
    expect(DirectedGraph().stronglyConnectedComponents(), isEmpty);

    final graph = DirectedGraph.fromMap({
      '1': ['0'],
      '0': ['2', '3'],
      '2': ['1'],
      '3': ['4'],
      '4': null,
    });

    expect(graph.stronglyConnectedComponents(), [
      ['4'],
      ['3'],
      unorderedEquals(['0', '1', '2'])
    ]);
  });
}
