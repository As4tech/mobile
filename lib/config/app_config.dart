class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static bool get useMockData => const bool.fromEnvironment('USE_MOCK');
}
