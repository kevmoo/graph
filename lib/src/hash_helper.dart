import 'dart:collection';

import 'pair.dart';

bool _defaultEquals(a, b) => a == b;

int _defaultHashCode(a) => a.hashCode;

abstract class HashHelper<K> {
  final bool Function(K key1, K key2) equalsField;
  final int Function(K) hashCodeField;

  factory HashHelper(
      bool Function(K key1, K key2) equals, int Function(K) hashCode) {
    if (equals == null && hashCode == null) {
      return _TrivialHashHelper();
    }

    return _HashHelperImpl(
        equals ?? _defaultEquals, hashCode ?? _defaultHashCode);
  }

  HashHelper._(this.equalsField, this.hashCodeField);

  HashSet<Pair<K>> createPairSet() =>
      HashSet<Pair<K>>(equals: _pairsEqual, hashCode: _pairHashCode);

  int _pairHashCode(Pair<K> pair);

  bool _pairsEqual(Pair<K> a, Pair<K> b);
}

class _HashHelperImpl<K> extends HashHelper<K> {
  _HashHelperImpl(
      bool Function(K key1, K key2) equalsField, int Function(K) hashCodeField)
      : super._(equalsField, hashCodeField);

  @override
  int _pairHashCode(Pair<K> pair) =>
      hashCodeField(pair.item2) ^ hashCodeField(pair.item2);

  @override
  bool _pairsEqual(Pair<K> a, Pair<K> b) =>
      (equalsField(a.item1, b.item1) && equalsField(a.item2, b.item2)) ||
      (equalsField(a.item1, b.item2) && equalsField(a.item2, b.item1));
}

class _TrivialHashHelper<K> extends HashHelper<K> {
  _TrivialHashHelper() : super._(null, null);

  @override
  int _pairHashCode(Pair<K> pair) => pair.item1.hashCode ^ pair.item2.hashCode;

  @override
  bool _pairsEqual(Pair<K> a, Pair<K> b) =>
      (a.item1 == b.item1 && a.item2 == b.item2) ||
      (a.item1 == b.item2 && a.item2 == b.item1);
}
