/// Represents a canonical pair of two items of type [T] where [item1] is less
/// than or equal to [item2] using [Comparable.compareTo] between the items.
///
/// ```dart
/// print(Pair(1, 2)); // (1, 2)
/// print(Pair(2, 1)); // (1, 2)
/// print((Pair(1, 2) == Pair(2, 1)); // true
/// ```
class Pair<T extends Comparable> {
  final T item1, item2;

  Pair._(this.item1, this.item2) {
    assert(item1.compareTo(item2) <= 0);
  }

  factory Pair(T itemA, T itemB) {
    if (itemA.compareTo(itemB) < 0) {
      return Pair._(itemA, itemB);
    }
    return Pair._(itemB, itemA);
  }

  @override
  bool operator ==(Object other) =>
      other is Pair && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => item1.hashCode * 31 ^ item2.hashCode;

  @override
  String toString() => '($item1, $item2)';
}
