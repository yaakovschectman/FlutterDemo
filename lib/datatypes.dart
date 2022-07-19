class Pair<T> {
  T first, second;
  Pair(this.first, this.second);
  @override
  bool operator ==(Object other) {
    return (other is Pair<T>) && other.first == first && other.second == second;
  }
  @override
  int get hashCode => first.hashCode + second.hashCode * 11;

}