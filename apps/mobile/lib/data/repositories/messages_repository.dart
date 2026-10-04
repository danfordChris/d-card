import 'package:dcard_api/api.dart';

import 'api_errors.dart';

class MessagesRepository {
  MessagesRepository(this._api);

  final DefaultApi _api;

  Future<MessageSettings> getMessageSettings(String eventId) async {
    return guardApi(() => _api.getMessageSettings(eventId));
  }

  Future<MessageSettings> updateMessageSettings(
    String eventId,
    UpdateMessageSettingsRequest request,
  ) async {
    return guardApi(
      () => _api.updateMessageSettings(eventId, updateMessageSettingsRequest: request),
    );
  }

  Future<MessageLog> listMessageLog(
    String eventId, {
    String? status,
    String? messageType,
    String? channel,
    int? limit,
    String? before,
  }) async {
    return guardApi(
      () => _api.listMessageLog(
        eventId,
        status: status,
        messageType: messageType,
        channel: channel,
        limit: limit,
        before: before,
      ),
    );
  }

  Future<SendManualMessage200Response> sendManualMessage(
    String eventId,
    SendManualMessageRequest request,
  ) async {
    return guardApi(
      () => _api.sendManualMessage(eventId, sendManualMessageRequest: request),
    );
  }
}
