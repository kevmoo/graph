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
}
