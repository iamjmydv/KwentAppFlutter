class AppRoutes {
  const AppRoutes._();

  static const feed = '/';
  static const profile = '/profile';
  static const login = '/login';
  static const register = '/register';
  static const postNew = '/post/new';
  static const postDetail = '/post/:id';
  static const postEdit = '/post/:id/edit';
  static const connectionCheck = '/connection-check';

  static String detailOf(String id) => '/post/$id';
  static String editOf(String id) => '/post/$id/edit';

  static const publicRoutes = <String>{feed, login, register, connectionCheck};

  static const authSiblingExtra = 'auth-sibling';
}
