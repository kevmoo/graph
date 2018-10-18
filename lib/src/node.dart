import 'edge.dart';

abstract class Node<Key, Data, EdgeData> implements Set<Edge<Key, EdgeData>> {
  Key get key;

  Data get data;

  bool edgeTo(Key other) => any((e) => e.target == other);
}
