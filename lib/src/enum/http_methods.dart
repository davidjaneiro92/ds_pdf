abstract class HttpMethods {
  static const post = 'POST';
  static const put = 'PUT';
  static const patch = 'PATCH';
  static const delete = 'DELETE';
  static const get = 'GET';

  final String method;
  const HttpMethods(this.method);
}