class Edge<Key, Data> {
  final Key target;
  final Data data;

  Edge(this.target, {this.data}) {
    assert(target != null, 'target cannot be null');
  }

  @override
  bool operator ==(Object other) =>
      other is Edge && other.target == target && other.data == data;

  @override
  int get hashCode => target.hashCode * 31 ^ data.hashCode;
}
