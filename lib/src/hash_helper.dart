import 'pair.dart';

bool _defaultEquals(a, b) => a == b;

int _defaultHashCode(a) => a.hashCode;

class HashHelper<K> {
  final bool Function(K key1, K key2) equalsField;
  final int Function(K) hashCodeField;

  factory HashHelper(
      bool Function(K key1, K key2) equals, int Function(K) hashCode) {
    if (equals == null && hashCode == null) {
      return _TrivialHashHelper();
    }

    return HashHelper._(equals ?? _defaultEquals, hashCode ?? _defaultHashCode);
  }

  HashHelper._(this.equalsField, this.hashCodeField);

  int pairHashCode(Pair<K> pair) =>
      hashCodeField(pair.item2) ^ hashCodeField(pair.item2);

  bool pairsEqual(Pair<K> a, Pair<K> b) =>
      (equalsField(a.item1, b.item1) && equalsField(a.item2, b.item2)) ||
      (equalsField(a.item1, b.item2) && equalsField(a.item2, b.item1));
}

class _TrivialHashHelper<K> implements HashHelper<K> {
  @override
  final bool Function(K key1, K key2) equalsField = null;
  @override
  final int Function(K) hashCodeField = null;

  @override
  int pairHashCode(Pair<K> pair) => pair.item1.hashCode ^ pair.item2.hashCode;

  @override
  bool pairsEqual(Pair<K> a, Pair<K> b) =>
      (a.item1 == b.item1 && a.item2 == b.item2) ||
      (a.item1 == b.item2 && a.item2 == b.item1);
}
