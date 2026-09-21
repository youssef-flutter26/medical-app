abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
