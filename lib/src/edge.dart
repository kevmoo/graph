class Edge<N, D> {
  final N target;
  final D data;

  Edge(this.target, {this.data});

  factory Edge.fromJson(Object json, {N Function(String) nodeConvert}) {
    nodeConvert ??= (String value) => value as N;

    if (json is Map) {
      return Edge(nodeConvert(json['target'] as String),
          data: json['data'] as D);
    }
    return Edge(nodeConvert(json as String));
  }

  @override
  bool operator ==(Object other) =>
      other is Edge && other.target == target && other.data == data;

  @override
  int get hashCode => target.hashCode * 31 + data.hashCode;

  Object toJson() {
    if (data == null) {
      return target.toString();
    }

    return {'target': target.toString(), 'data': data};
  }
}
