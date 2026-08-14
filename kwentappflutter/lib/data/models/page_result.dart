import 'package:kwentappflutter/core/utils/list_equality.dart';

class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  const PageResult.empty() : items = const [], hasMore = false;

  final List<T> items;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageResult<T> &&
          areListsEqual(other.items, items) &&
          other.hasMore == hasMore;

  @override
  int get hashCode => Object.hash(Object.hashAll(items), hasMore);
}
