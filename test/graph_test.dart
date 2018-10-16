import 'dart:convert';

import 'package:graph/graph.dart';
import 'package:test/test.dart';

void main() {
  group('simple', () {
    DirectedGraph<int, String> graph;

    setUp(() {
      graph = DirectedGraph<int, String>();
    });

    test('a new graph is empty', () {
      expect(graph.nodeCount, 0);
      expect(graph.edgeCount, 0);
    });

    // each Node corresponds to a "Node Data" object - ND
    // NDs are expected to have value semantics – equals/hashCode/immutable

    test('null node not allowed', () {
      expect(() => graph.add(null), throwsArgumentError);
    });

    test('adding the same edge twice is a no-op', () {
      expect(graph.add(1), isTrue);
      expect(graph.nodeCount, 1);
      expect(graph.add(1), isFalse);
      expect(graph.nodeCount, 1);
    });

    test('removing a node that does not exist returns false/null', () {
      expect(graph.removeNode(1), isFalse);
    });

    test('removing an existing node removes the node and all edges', () {
      graph.addEdge(1, 2);
      graph.addEdge(2, 1);
      expect(graph.nodeCount, 2);
      expect(graph.edgeCount, 2);
      expect(graph.nodes, [1, 2]);

      expect(graph.removeNode(1), isTrue);
      expect(graph.nodeCount, 1);
      expect(graph.edgeCount, 0);
      expect(graph.nodes, [2]);
    });

    // Each edge corresponds to a "Edge Data" object - ED
    // EDs are expected to have value semantics - equal/hashCode/immutable
    // Removing an edge does not affect the nodes it connects
    group('edges', () {
      test('adding to/from a null node is not allowed', () {
        expect(() => graph.addEdge(null, null), throwsArgumentError);
        expect(() => graph.addEdge(null, 1), throwsArgumentError);
        expect(() => graph.addEdge(1, null), throwsArgumentError);
      });

      test('node self edges are okay', () {
        expect(graph.addEdge(1, 1), isTrue);
        expect(graph.nodeCount, 1);
        expect(graph.edgeCount, 1);
      });

      test('adding an edge with new node data adds that data to the graph', () {
        expect(graph.addEdge(1, 2), isTrue);
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 1);

        expect(graph.addEdge(1, 2), isFalse);
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 1, reason: 'nothing added');

        graph.addEdge(1, 2, edgeData: 'data');
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 2, reason: 'different edge data');
      });

      test('removing a non-existant edge retuns `false`', () {
        graph.addEdge(1, 2);
        graph.addEdge(2, 1);
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 2);

        expect(graph.removeEdge(2, 3), isFalse);
        expect(graph.removeEdge(1, 3), isFalse);
        expect(graph.removeEdge(1, 2, edgeData: 'data'), isFalse);
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 2);
      });

      test('removing an existing edge returns `true`', () {
        graph.addEdge(1, 2, edgeData: '1->2');
        graph.addEdge(2, 1, edgeData: '2->1');
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 2);

        expect(graph.removeEdge(1, 2), isFalse);
        expect(graph.removeEdge(2, 1, edgeData: '1->2'), isFalse);
        expect(graph.removeEdge(1, 2, edgeData: '1->2'), isTrue);
        expect(graph.nodeCount, 2);
        expect(graph.edgeCount, 1);
      });
    });

    group('connected', () {
      test('empty graph has no connection', () {
        expect(graph.connected(0, 1), isFalse);
        expect(graph.connectedNodes, isEmpty);
      });

      test('self link', () {
        graph.addEdge(1, 1);
        graph.addEdge(1, 1, edgeData: 'self');
        expect(graph.nodeCount, 1);
        expect(graph.edgeCount, 2);
        expect(graph.connected(1, 1), isTrue);

        expect(graph.connected(1, 1), isTrue);
        expect(graph.connectedNodes.single, const Pair(1, 1));
      });

      test('many links', () {
        [1, 2, 3, 4, 5].forEach(graph.add);
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 0);
        expect(graph.connectedNodes, isEmpty);

        for (var i = 1; i < 5; i++) {
          graph.addEdge(i, i + 1);
        }
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 4);

        final expectedPairs = const [
          Pair(1, 2),
          Pair(2, 3),
          Pair(3, 4),
          Pair(4, 5)
        ];

        expect(graph.connectedNodes, unorderedEquals(expectedPairs));

        // Adding extra data to each connection doesn't change `connectedNodes`
        for (var i = 1; i < 5; i++) {
          graph.addEdge(i, i + 1, edgeData: 'extra data');
        }
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 8);

        expect(graph.connectedNodes, unorderedEquals(expectedPairs));

        // Adding edges going the other way doesn't change `connectedNodes`
        for (var i = 1; i < 5; i++) {
          graph.addEdge(i + 1, i);
        }
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 12);
        expect(graph.connectedNodes, unorderedEquals(expectedPairs));

        // Complete the circle, start -> end
        expect(graph.addEdge(1, 5), isTrue);
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 13);

        expect(graph.connectedNodes,
            unorderedEquals(expectedPairs.followedBy(const [Pair(1, 5)])));

        // remove just added connection
        expect(graph.removeEdge(1, 5), isTrue);
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 12);
        expect(graph.connectedNodes, unorderedEquals(expectedPairs));

        // Complete the circle, end -> start
        expect(graph.addEdge(5, 1), isTrue);
        expect(graph.nodeCount, 5);
        expect(graph.edgeCount, 13);

        expect(graph.connectedNodes,
            unorderedEquals(expectedPairs.followedBy(const [Pair(1, 5)])));

        for (var pair in graph.connectedNodes) {
          expect(graph.connected(pair.item1, pair.item2), isTrue);
          expect(graph.connected(pair.item2, pair.item1), isTrue);
        }
      });
    });
  });

  group('json', () {
    test('toJson', () {
      final graph = DirectedGraph<String, String>();
      expect(_encodeDecode(graph.toJson()), {});

      graph.add('a');
      graph.add('b');
      expect(_encodeDecode(graph.toJson()), {'a': [], 'b': []});

      graph.addEdge('a', 'b');
      expect(_encodeDecode(graph.toJson()), {
        'a': [
          {'target': 'b'}
        ],
        'b': []
      });

      graph.addEdge('a', 'b', edgeData: 'data');
      _expectDirectedGraphOutputEqual(graph, {
        'a': [
          {'target': 'b'},
          {'target': 'b', 'data': 'data'}
        ],
        'b': []
      });
    });

    test('fromJson', () {
      final json = {
        'a': [
          {'target': 'b'},
          {'target': 'b', 'data': 'data'}
        ],
        'b': []
      };
      final graph = DirectedGraph<String, String>.fromJson(json);

      _expectDirectedGraphOutputEqual(graph, json);
    });

    test('fromJson asserts on inconsistant input', () {
      final json = {
        'a': [
          {'target': 'b'},
          {'target': 'b', 'data': 'data'}
        ]
      };

      expect(() => DirectedGraph<String, String>.fromJson(json),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('to/fromJson with conversions', () {
      final json = {
        '1': [
          {'target': '2'},
          {'target': '2', 'data': 2}
        ],
        '2': []
      };

      expect(() => DirectedGraph<int, int>.fromJson(json),
          throwsA(const TypeMatcher<CastError>()));

      final graph =
          DirectedGraph<int, int>.fromJson(json, nodeConvert: int.parse);

      _expectDirectedGraphOutputEqual(graph, json);
    });
  });
}

void _expectDirectedGraphOutputEqual(
    DirectedGraph graph, Map<String, dynamic> expected) {
  final prettyEncode =
      const JsonEncoder.withIndent(' ').convert(graph.toJson());

  //printOnFailure(prettyEncode);

  final actual = jsonDecode(prettyEncode) as Map<String, dynamic>;

  expect(actual.keys, expected.keys);
  for (var key in expected.keys) {
    expect(actual, containsPair(key, unorderedEquals(expected[key] as List)));
  }
}

Object _encodeDecode(Object source) {
  try {
    return jsonDecode(jsonEncode(source));
  } on JsonUnsupportedObjectError catch (e) {
    print([e.unsupportedObject, e.cause, e.partialResult]);
    rethrow;
  }
}
