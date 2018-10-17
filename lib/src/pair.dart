class Pair<T extends Comparable> {
  final T item1, item2;

  Pair._(this.item1, this.item2) {
    assert(item1.compareTo(item2) <= 0);
  }

  factory Pair(T item1, T item2) {
    if (item1.compareTo(item2) <= 0) {
      return Pair._(item1, item2);
    }
    return Pair._(item2, item1);
  }

  @override
  bool operator ==(Object other) =>
      other is Pair && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => item1.hashCode * 31 ^ item2.hashCode;

  @override
  String toString() => '($item1, $item2)';
}
