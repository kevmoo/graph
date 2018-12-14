import 'dart:math' show Random;

import 'package:graph/graph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() {
  final graph = DirectedGraph.fromMap(<String, List<String>>{
    'a': ['b', 'e'],
    'b': ['c'],
    'c': ['d', 'e'],
    'd': ['a'],
    'e': ['h'],
    'f': ['g'],
    'g': null,
    'h': null,
  });

  // Treat `graph` above as unweighted
  void _singlePathTest(String from, String to, List<String> expected) {
    test('$from -> $to', () {
      expect(graph.shortestPath(from, to), expected);
    });
  }

  void _pathsTest(
      String from, Map<String, List<String>> expected, List<String> nullPaths) {
    test('paths from $from', () {
      final result = graph.shortestPaths(from);
      expect(result, expected);
    });

    for (var entry in expected.entries) {
      _singlePathTest(from, entry.key, entry.value);
    }

    for (var entry in nullPaths) {
      _singlePathTest(from, entry, null);
    }
  }

  _pathsTest('a', {
    'e': ['e'],
    'c': ['b', 'c'],
    'h': ['e', 'h'],
    'a': [],
    'b': ['b'],
    'd': ['b', 'c', 'd'],
  }, [
    'f',
    'g',
  ]);

  _pathsTest('f', {
    'g': ['g'],
    'f': [],
  }, [
    'a',
  ]);
  _pathsTest('g', {'g': []}, ['a', 'f']);

  test('non-existant start values are not allowed', () {
    expect(() => graph.shortestPath('not here', 'a'),
        throwsAssertionError('graph does not contain `start`.'));
    expect(() => graph.shortestPaths('not here'),
        throwsAssertionError('graph does not contain `start`.'));
  });

  test('non-existant target values are not allowed', () {
    expect(() => graph.shortestPath('a', 'not here'),
        throwsAssertionError('graph does not contain `target`.'));
  });

  test('integration test', () {
    // Be deterministic in the generated graph. This test may have to be updated
    // if the behavior of `Random` changes for the provided seed.
    final _rnd = Random(1);
    final size = 1000;
    final graph = DirectedGraph<int, dynamic>();

    List<int> resultForGraph() {
      try {
        return graph.shortestPath(0, size - 1);
      } on AssertionError {
        return null;
      }
    }

    void addRandomEdge() {
      graph.addEdge(_rnd.nextInt(size), _rnd.nextInt(size));
    }

    List<int> result;

    // Add edges until there is a shortest path between `0` and `size - 1`
    do {
      addRandomEdge();
      result = resultForGraph();
    } while (result == null);

    expect(result, [313, 547, 91, 481, 74, 64, 439, 388, 660, 275, 999]);

    var count = 0;
    // Add edges until the shortest path between `0` and `size - 1` is 2 items
    // Adding edges should never increase the length of the shortest path.
    // Adding enough edges should reduce the length of the shortest path.
    do {
      expect(++count, lessThan(size * 5), reason: 'This loop should finish.');
      addRandomEdge();
      final previousResultLength = result.length;
      result = resultForGraph();
      expect(result, hasLength(lessThanOrEqualTo(previousResultLength)));
    } while (result.length > 2);

    expect(result, [275, 999]);

    count = 0;
    // Remove edges until there is no shortest path.
    // Removing edges should never reduce the length of the shortest path.
    // Removing enough edges should increase the length of the shortest path and
    // eventually eliminate any path.
    do {
      expect(++count, lessThan(size * 5), reason: 'This loop should finish.');

      final randomKey = graph.nodes.elementAt(_rnd.nextInt(graph.nodeCount));
      final list = graph.edgesFrom(randomKey).toList();

      if (list.isNotEmpty) {
        expect(list, isNotEmpty);

        expect(
            graph.removeEdge(
                randomKey, list.elementAt(_rnd.nextInt(list.length))),
            isTrue);
        if (list.length == 1) {
          expect(graph.removeNode(randomKey), isTrue);
        }
      }

      final previousResultLength = result.length;
      result = resultForGraph();
      if (result != null) {
        expect(result, hasLength(greaterThanOrEqualTo(previousResultLength)));
      }
    } while (result != null);
  });
}
