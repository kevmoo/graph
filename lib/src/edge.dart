class Edge<N, D> {
  final N target;
  final D data;

  Edge(this.target, {this.data});

  factory Edge.fromJson(Map<String, dynamic> json,
      {N Function(String) nodeConvert}) {
    nodeConvert ??= (String value) => value as N;

    return Edge(nodeConvert(json['target'] as String), data: json['data'] as D);
  }

  @override
  bool operator ==(Object other) =>
      other is Edge && other.target == target && other.data == data;

  @override
  int get hashCode => target.hashCode * 31 + data.hashCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'target': target.toString()};
    if (data != null) {
      map['data'] = data;
    }
    return map;
  }
}
