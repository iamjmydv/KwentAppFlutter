import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/data/repositories/comment_repository.dart';
import 'package:kwentappflutter/data/repositories/post_repository.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/supabase_auth_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/supabase_comment_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/supabase_post_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/supabase_profile_repository.dart';
import 'package:kwentappflutter/data/services/auth_service.dart';
import 'package:kwentappflutter/data/services/database_service.dart';
import 'package:kwentappflutter/data/services/storage_service.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<SingleChildWidget> buildAppProviders(SupabaseClient client) {
  final auth = AuthService(client);
  final database = DatabaseService(client);
  final storage = StorageService(client);

  final authRepository = SupabaseAuthRepository(auth);

  return [
    Provider<AuthService>.value(value: auth),
    Provider<DatabaseService>.value(value: database),
    Provider<StorageService>.value(value: storage),
    Provider<AuthRepository>.value(value: authRepository),
    Provider<PostRepository>.value(
      value: SupabasePostRepository(database, storage, auth),
    ),
    Provider<CommentRepository>.value(
      value: SupabaseCommentRepository(database, storage, auth),
    ),
    Provider<ProfileRepository>.value(
      value: SupabaseProfileRepository(database, storage),
    ),
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => AuthViewModel(authRepository),
    ),
  ];
}
