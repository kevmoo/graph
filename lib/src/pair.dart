/// Represents 2 values of type [T] where equality comparisons between two
/// instances is order independent.
///
/// Explicitly, two [Pair] instances are considered equal if
/// `a.item1 == b.item1 && a.item2 == b.item2`
/// or if
/// `a.item1 == b.item2 && a.item2 == b.item1`.
///
/// [hashCode] also remains the same if [item1] and [item2] are swapped.
class Pair<T> {
  final T item1, item2;

  const Pair(this.item1, this.item2);

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
