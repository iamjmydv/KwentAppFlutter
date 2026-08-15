class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://izsxbnoshvorpfztbrzp.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_hjZpvm4_pcfKCpTIk_G6Bg_Dnvin2gs',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
