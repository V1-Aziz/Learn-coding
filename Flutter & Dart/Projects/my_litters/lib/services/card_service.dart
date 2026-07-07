import '../models/card.dart';
import 'api_client.dart';

class CardService {
  CardService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  Future<List<FuelCard>> list() async {
    final data = await _api.get('/api/cards') as List<dynamic>;
    return data
        .map((j) => FuelCard.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<FuelCard> link({required String cardUid, String? label}) async {
    final data = await _api.post('/api/cards', body: {
      'cardUid': cardUid,
      if (label != null && label.isNotEmpty) 'label': label,
    });
    return FuelCard.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<FuelCard> block(String cardId) async {
    final data = await _api.post('/api/cards/$cardId/block');
    return FuelCard.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<FuelCard> unblock(String cardId) async {
    final data = await _api.post('/api/cards/$cardId/unblock');
    return FuelCard.fromJson((data as Map).cast<String, dynamic>());
  }
}
