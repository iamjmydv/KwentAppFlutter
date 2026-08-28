import 'dart:async';

import 'package:kwentappflutter/data/models/post.dart';
import 'package:kwentappflutter/data/models/profile.dart';

sealed class DomainEvent {
  const DomainEvent();
}

class PostCreated extends DomainEvent {
  const PostCreated(this.post);

  final Post post;
}

class PostUpdated extends DomainEvent {
  const PostUpdated(this.post);

  final Post post;
}

class PostDeleted extends DomainEvent {
  const PostDeleted(this.postId);

  final String postId;
}

class CommentCountChanged extends DomainEvent {
  const CommentCountChanged({required this.postId, required this.delta});

  final String postId;
  final int delta;
}

class ProfileChanged extends DomainEvent {
  const ProfileChanged(this.profile);

  final Profile profile;
}

class AppEventBus {
  final _controller = StreamController<DomainEvent>.broadcast();

  Stream<DomainEvent> get events => _controller.stream;

  void publish(DomainEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  void dispose() => _controller.close();
}
