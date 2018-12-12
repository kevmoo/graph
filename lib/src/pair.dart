class Pair<T> {
  final T item1, item2;

  Pair(this.item1, this.item2);

  @override
  bool operator ==(Object other) =>
      other is Pair &&
      ((other.item1 == item1 && other.item2 == item2) ||
          (other.item1 == item2 && other.item2 == item1));

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;

  @override
  String toString() => '($item1, $item2)';
}
