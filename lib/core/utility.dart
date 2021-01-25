class ReplaceRecord {
  final String from;
  final String to;
  const ReplaceRecord(this.from, this.to);
}

String replaceAll(String target, List<ReplaceRecord> records) {
  var froms = [];
  var map = {};
  for (var r in records) {
    froms.add(r.from);
    map[r.from] = r.to;
  }
  return target.replaceAllMapped(RegExp(froms.join('|')), (m) => map[m[0]]);
}
