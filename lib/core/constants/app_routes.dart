/// Named routes. The web build exposes them under the hash strategy, so
/// `/#/admin` is a shareable deep link straight to the admin page.
abstract final class AppRoutes {
  static const String dashboard = '/';
  static const String admin = '/admin';
}
