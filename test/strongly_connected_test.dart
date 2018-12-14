import 'package:graph/graph.dart';
import 'package:test/test.dart';

void main() {
  test('empty', () {
    expect(DirectedGraph().stronglyConnectedComponents(), isEmpty);
  });

  test('example 1', () {
    final graph = DirectedGraph.fromMap({
      '1': ['0'],
      '0': ['2', '3'],
      '2': ['1'],
      '3': ['4'],
      '4': null,
    });

    final expected = [
      ['4'],
      ['3'],
      ['0', '1', '2'],
    ];

    expect(graph.stronglyConnectedComponents(), expected.map(unorderedEquals));
  });

  test('example 2', () {
    // https://en.wikipedia.org/wiki/Strongly_connected_component#/media/File:Scc.png
    // 2018-12-14
    final graph = DirectedGraph.fromMap({
      'a': ['b'],
      'b': ['e', 'f', 'c'],
      'c': ['d', 'g'],
      'd': ['h', 'c'],
      'e': ['a', 'f'],
      'f': ['g'],
      'g': ['f'],
      'h': ['d'],
    });

    final expected = [
      ['f', 'g'],
      ['h', 'd', 'c'],
      ['b', 'a', 'e'],
    ];

    expect(graph.stronglyConnectedComponents(), expected.map(unorderedEquals));
  });
}
