import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enrichment/enrichment_client.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override sharedPreferencesProvider in main'),
);

const _kServiceUrlKey = 'service_base_url';
const _kContentWeightKey = 'content_weight';

/// Default LAN service URL = this PC's detected Wi-Fi IP, so enrichment works
/// out of the box. Change it in Settings if your IP differs.
const String kDefaultServiceUrl = 'http://192.168.0.100:8973';

/// LAN enrichment service base URL, e.g. `http://192.168.1.20:8973`.
class ServiceUrlNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.read(sharedPreferencesProvider).getString(_kServiceUrlKey) ??
      kDefaultServiceUrl;

  Future<void> set(String url) async {
    final value = url.trim();
    await ref.read(sharedPreferencesProvider).setString(_kServiceUrlKey, value);
    state = value;
  }
}

final serviceUrlProvider =
    NotifierProvider<ServiceUrlNotifier, String>(ServiceUrlNotifier.new);

/// Blend weight for content-based vs collaborative scores (0..1). Default 0.6
/// content per the spec; collaborative weight is `1 - content`.
class ContentWeightNotifier extends Notifier<double> {
  @override
  double build() =>
      ref.read(sharedPreferencesProvider).getDouble(_kContentWeightKey) ?? 0.6;

  Future<void> set(double w) async {
    final value = w.clamp(0.0, 1.0);
    await ref.read(sharedPreferencesProvider).setDouble(_kContentWeightKey, value);
    state = value;
  }
}

final contentWeightProvider =
    NotifierProvider<ContentWeightNotifier, double>(ContentWeightNotifier.new);

/// Enrichment client, or null when no service URL is configured.
final enrichmentClientProvider = Provider<EnrichmentClient?>((ref) {
  final url = ref.watch(serviceUrlProvider);
  if (url.isEmpty) return null;
  final client = EnrichmentClient(url);
  ref.onDispose(client.close);
  return client;
});
