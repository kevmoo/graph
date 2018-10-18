class Edge<K, D> {
  final K target;
  final D data;

  Edge(this.target, {this.data});

  @override
  bool operator ==(Object other) =>
      other is Edge && other.target == target && other.data == data;

  @override
  int get hashCode => target.hashCode * 31 + data.hashCode;
}
