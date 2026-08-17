import 'package:kwentappflutter/core/resources/strings.dart';

String timeAgo(DateTime moment, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final elapsed = reference.difference(moment);

  if (elapsed.isNegative || elapsed.inSeconds < 60) return Strings.justNow;
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';
  if (elapsed.inDays < 365) return '${elapsed.inDays ~/ 7}w ago';

  return '${elapsed.inDays ~/ 365}y ago';
}

String commentCountLabel(int count) {
  if (count <= 0) return Strings.noComments;
  if (count == 1) return Strings.oneComment;
  return '$count comments';
}
