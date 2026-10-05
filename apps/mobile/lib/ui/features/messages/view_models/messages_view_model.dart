import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/messages_repository.dart';
import '../../../../domain/models/app_failure.dart';

class MessagesViewModel extends ChangeNotifier {
  MessagesViewModel({required this.eventId, required this.repository});

  final String eventId;
  final MessagesRepository repository;

  bool loading = false;
  AppFailure? failure;

  List<UpdateMessageSettingsRequestSettingsInner> settings = const [];
  MessagePlanLimits? limits;
  MessageSettingsUsage? usage;

  List<MessageLogItemsInner> logItems = const [];
  Map<String, int> logCounts = const {};
  bool logLoading = false;
  String? logNextBefore;
  bool logHasMore = true;

  bool saving = false;

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.getMessageSettings(eventId),
        repository.listMessageLog(eventId, limit: 20),
      ]);
      final ms = results[0] as MessageSettings;
      settings = ms.settings;
      limits = ms.limits;
      usage = ms.usage;

      final log = results[1] as MessageLog;
      logItems = log.items;
      logCounts = log.counts;
      logNextBefore = log.nextBefore;
      logHasMore = log.nextBefore != null;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSetting(int index) async {
    if (saving) return;
    final updated = List<UpdateMessageSettingsRequestSettingsInner>.from(settings);
    final s = updated[index];
    updated[index] = UpdateMessageSettingsRequestSettingsInner(
      messageType: s.messageType,
      enabled: !s.enabled,
      channels: s.channels,
      smsTextSw: s.smsTextSw,
      smsTextEn: s.smsTextEn,
      whatsappTemplateVariant: s.whatsappTemplateVariant,
      whatsappNote: s.whatsappNote,
      schedule: s.schedule,
    );
    settings = updated;
    saving = true;
    notifyListeners();
    try {
      final ms = await repository.updateMessageSettings(
        eventId,
        UpdateMessageSettingsRequest(settings: updated),
      );
      settings = ms.settings;
      limits = ms.limits;
      usage = ms.usage;
    } on AppException catch (e) {
      failure = e.failure;
      settings[index] = s;
    } catch (_) {
      failure = AppFailure.unknown;
      settings[index] = s;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreLog() async {
    if (logLoading || !logHasMore) return;
    logLoading = true;
    notifyListeners();
    try {
      final log = await repository.listMessageLog(
        eventId,
        limit: 20,
        before: logNextBefore,
      );
      logItems = [...logItems, ...log.items];
      logCounts = log.counts;
      logNextBefore = log.nextBefore;
      logHasMore = log.nextBefore != null;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      logLoading = false;
      notifyListeners();
    }
  }
}
