abstract class Node<Key, Data, EdgeData> implements Map<Key, Set<EdgeData>> {
  Data get data;
}
