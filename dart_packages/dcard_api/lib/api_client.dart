//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ApiClient {
  ApiClient({this.basePath = 'http://localhost', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType,
  ) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = StreamedRequest(method, uri);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = MultipartRequest(method, uri);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      switch(method) {
        case 'POST': return await _client.post(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PUT': return await _client.put(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'DELETE': return await _client.delete(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'PATCH': return await _client.patch(uri, headers: nullableHeaderParams, body: msgBody,);
        case 'HEAD': return await _client.head(uri, headers: nullableHeaderParams,);
        case 'GET': return await _client.get(uri, headers: nullableHeaderParams,);
      }
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }

    throw ApiException(
      HttpStatus.badRequest,
      'Invalid HTTP operation: $method $path',
    );
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'Account':
          return Account.fromJson(value);
        case 'AdminAuditEntry':
          return AdminAuditEntry.fromJson(value);
        case 'AdminAuditPage':
          return AdminAuditPage.fromJson(value);
        case 'AdminCreateProviderRateRequest':
          return AdminCreateProviderRateRequest.fromJson(value);
        case 'AdminCreateWhatsappTemplateRequest':
          return AdminCreateWhatsappTemplateRequest.fromJson(value);
        case 'AdminEvent':
          return AdminEvent.fromJson(value);
        case 'AdminEventPage':
          return AdminEventPage.fromJson(value);
        case 'AdminEventType':
          return AdminEventType.fromJson(value);
        case 'AdminEventTypeCreateInput':
          return AdminEventTypeCreateInput.fromJson(value);
        case 'AdminEventTypeList':
          return AdminEventTypeList.fromJson(value);
        case 'AdminEventTypeUpdateInput':
          return AdminEventTypeUpdateInput.fromJson(value);
        case 'AdminListProviderRates200Response':
          return AdminListProviderRates200Response.fromJson(value);
        case 'AdminListProviderRates200ResponseRatesInner':
          return AdminListProviderRates200ResponseRatesInner.fromJson(value);
        case 'AdminListWhatsappTemplates200Response':
          return AdminListWhatsappTemplates200Response.fromJson(value);
        case 'AdminListWhatsappTemplates200ResponseTemplatesInner':
          return AdminListWhatsappTemplates200ResponseTemplatesInner.fromJson(value);
        case 'AdminUpdateWhatsappTemplateRequest':
          return AdminUpdateWhatsappTemplateRequest.fromJson(value);
        case 'AdminUser':
          return AdminUser.fromJson(value);
        case 'AdminUserPage':
          return AdminUserPage.fromJson(value);
        case 'AdminUserUpdateInput':
          return AdminUserUpdateInput.fromJson(value);
        case 'AuditChange':
          return AuditChange.fromJson(value);
        case 'AuthProvider':
          return AuthProviderTypeTransformer().decode(value);
        case 'BillingQuote':
          return BillingQuote.fromJson(value);
        case 'BillingQuoteInput':
          return BillingQuoteInput.fromJson(value);
        case 'BillingQuoteLine':
          return BillingQuoteLine.fromJson(value);
        case 'BillingSettings':
          return BillingSettings.fromJson(value);
        case 'BillingSummary':
          return BillingSummary.fromJson(value);
        case 'Card':
          return Card.fromJson(value);
        case 'CardLink':
          return CardLink.fromJson(value);
        case 'CardType':
          return CardTypeTypeTransformer().decode(value);
        case 'CheckInMethod':
          return CheckInMethodTypeTransformer().decode(value);
        case 'CheckoutInput':
          return CheckoutInput.fromJson(value);
        case 'Contributions':
          return Contributions.fromJson(value);
        case 'ContributionsSummary':
          return ContributionsSummary.fromJson(value);
        case 'ContributionsSummaryCounts':
          return ContributionsSummaryCounts.fromJson(value);
        case 'ContributorCreateInput':
          return ContributorCreateInput.fromJson(value);
        case 'ContributorCreateResponse':
          return ContributorCreateResponse.fromJson(value);
        case 'CostLine':
          return CostLine.fromJson(value);
        case 'CostReport':
          return CostReport.fromJson(value);
        case 'CostReportEvent':
          return CostReportEvent.fromJson(value);
        case 'CostReportMonth':
          return CostReportMonth.fromJson(value);
        case 'CostReportPlan':
          return CostReportPlan.fromJson(value);
        case 'Device':
          return Device.fromJson(value);
        case 'DeviceApp':
          return DeviceAppTypeTransformer().decode(value);
        case 'DevicePlatform':
          return DevicePlatformTypeTransformer().decode(value);
        case 'DeviceRegisterInput':
          return DeviceRegisterInput.fromJson(value);
        case 'DoorCard':
          return DoorCard.fromJson(value);
        case 'DoorDevice':
          return DoorDevice.fromJson(value);
        case 'DoorDeviceRegisterInput':
          return DoorDeviceRegisterInput.fromJson(value);
        case 'DoorEntry':
          return DoorEntry.fromJson(value);
        case 'DoorEntryInput':
          return DoorEntryInput.fromJson(value);
        case 'DoorEntryResult':
          return DoorEntryResult.fromJson(value);
        case 'DoorEvent':
          return DoorEvent.fromJson(value);
        case 'DoorLookupInput':
          return DoorLookupInput.fromJson(value);
        case 'DoorLookupResult':
          return DoorLookupResult.fromJson(value);
        case 'DoorRefusal':
          return DoorRefusal.fromJson(value);
        case 'DoorRefusalCard':
          return DoorRefusalCard.fromJson(value);
        case 'DoorRefusalError':
          return DoorRefusalError.fromJson(value);
        case 'DoorSyncAttemptInput':
          return DoorSyncAttemptInput.fromJson(value);
        case 'DoorSyncCard':
          return DoorSyncCard.fromJson(value);
        case 'DoorSyncEntryInput':
          return DoorSyncEntryInput.fromJson(value);
        case 'DoorSyncResult':
          return DoorSyncResult.fromJson(value);
        case 'DoorSyncSnapshot':
          return DoorSyncSnapshot.fromJson(value);
        case 'DoorSyncSnapshotApproversInner':
          return DoorSyncSnapshotApproversInner.fromJson(value);
        case 'DoorSyncUpload':
          return DoorSyncUpload.fromJson(value);
        case 'ErrorResponse':
          return ErrorResponse.fromJson(value);
        case 'ErrorResponseError':
          return ErrorResponseError.fromJson(value);
        case 'ErrorResponseErrorIssuesInner':
          return ErrorResponseErrorIssuesInner.fromJson(value);
        case 'Event':
          return Event.fromJson(value);
        case 'EventAuditEntry':
          return EventAuditEntry.fromJson(value);
        case 'EventAuditPage':
          return EventAuditPage.fromJson(value);
        case 'EventCreateInput':
          return EventCreateInput.fromJson(value);
        case 'EventList':
          return EventList.fromJson(value);
        case 'EventPlan':
          return EventPlan.fromJson(value);
        case 'EventType':
          return EventType.fromJson(value);
        case 'EventTypeList':
          return EventTypeList.fromJson(value);
        case 'EventUpdateInput':
          return EventUpdateInput.fromJson(value);
        case 'ExportKind':
          return ExportKindTypeTransformer().decode(value);
        case 'Guest':
          return Guest.fromJson(value);
        case 'GuestBulkInput':
          return GuestBulkInput.fromJson(value);
        case 'GuestBulkInputGuestsInner':
          return GuestBulkInputGuestsInner.fromJson(value);
        case 'GuestBulkResponse':
          return GuestBulkResponse.fromJson(value);
        case 'GuestBulkResponseInvalidInner':
          return GuestBulkResponseInvalidInner.fromJson(value);
        case 'GuestCreateInput':
          return GuestCreateInput.fromJson(value);
        case 'GuestCreateResponse':
          return GuestCreateResponse.fromJson(value);
        case 'GuestMedia':
          return GuestMedia.fromJson(value);
        case 'GuestPage':
          return GuestPage.fromJson(value);
        case 'GuestUpdateInput':
          return GuestUpdateInput.fromJson(value);
        case 'HealthResponse':
          return HealthResponse.fromJson(value);
        case 'HostPayment':
          return HostPayment.fromJson(value);
        case 'HostPaymentMethod':
          return HostPaymentMethodTypeTransformer().decode(value);
        case 'ImportConfirmInput':
          return ImportConfirmInput.fromJson(value);
        case 'ImportCopyInput':
          return ImportCopyInput.fromJson(value);
        case 'ImportPreview':
          return ImportPreview.fromJson(value);
        case 'ImportReport':
          return ImportReport.fromJson(value);
        case 'ImportReportDuplicatesInFileInner':
          return ImportReportDuplicatesInFileInner.fromJson(value);
        case 'ImportReportExistingInner':
          return ImportReportExistingInner.fromJson(value);
        case 'ImportReportInvalidInner':
          return ImportReportInvalidInner.fromJson(value);
        case 'ImportResult':
          return ImportResult.fromJson(value);
        case 'Invite':
          return Invite.fromJson(value);
        case 'InviteAccepted':
          return InviteAccepted.fromJson(value);
        case 'InviteCreateInput':
          return InviteCreateInput.fromJson(value);
        case 'InviteCreateResponse':
          return InviteCreateResponse.fromJson(value);
        case 'InviteInfo':
          return InviteInfo.fromJson(value);
        case 'LinkCardInput':
          return LinkCardInput.fromJson(value);
        case 'LinkCardResult':
          return LinkCardResult.fromJson(value);
        case 'ListConfirmations200Response':
          return ListConfirmations200Response.fromJson(value);
        case 'ListConfirmations200ResponseCounts':
          return ListConfirmations200ResponseCounts.fromJson(value);
        case 'ListConfirmations200ResponseGuestsInner':
          return ListConfirmations200ResponseGuestsInner.fromJson(value);
        case 'ListDoorDevices200Response':
          return ListDoorDevices200Response.fromJson(value);
        case 'ListDoorEvents200Response':
          return ListDoorEvents200Response.fromJson(value);
        case 'ListEventMedia200Response':
          return ListEventMedia200Response.fromJson(value);
        case 'ListWalkIns200Response':
          return ListWalkIns200Response.fromJson(value);
        case 'MediaItem':
          return MediaItem.fromJson(value);
        case 'MediaKind':
          return MediaKindTypeTransformer().decode(value);
        case 'MediaLimits':
          return MediaLimits.fromJson(value);
        case 'MediaSettings':
          return MediaSettings.fromJson(value);
        case 'MediaSettingsCounts':
          return MediaSettingsCounts.fromJson(value);
        case 'MediaSettingsInput':
          return MediaSettingsInput.fromJson(value);
        case 'MediaStatus':
          return MediaStatusTypeTransformer().decode(value);
        case 'MediaStatusInput':
          return MediaStatusInput.fromJson(value);
        case 'MediaType':
          return MediaTypeTypeTransformer().decode(value);
        case 'MessageLog':
          return MessageLog.fromJson(value);
        case 'MessageLogItemsInner':
          return MessageLogItemsInner.fromJson(value);
        case 'MessageLogOptOutsInner':
          return MessageLogOptOutsInner.fromJson(value);
        case 'MessagePlanLimits':
          return MessagePlanLimits.fromJson(value);
        case 'MessageSettings':
          return MessageSettings.fromJson(value);
        case 'MessageSettingsTemplatesInner':
          return MessageSettingsTemplatesInner.fromJson(value);
        case 'MessageSettingsUsage':
          return MessageSettingsUsage.fromJson(value);
        case 'MyCard':
          return MyCard.fromJson(value);
        case 'MyCardList':
          return MyCardList.fromJson(value);
        case 'OfflineWalkInInput':
          return OfflineWalkInInput.fromJson(value);
        case 'Payment':
          return Payment.fromJson(value);
        case 'PaymentAttempt':
          return PaymentAttempt.fromJson(value);
        case 'PaymentCreateInput':
          return PaymentCreateInput.fromJson(value);
        case 'PaymentMethod':
          return PaymentMethodTypeTransformer().decode(value);
        case 'PaymentResult':
          return PaymentResult.fromJson(value);
        case 'PaymentStatus':
          return PaymentStatusTypeTransformer().decode(value);
        case 'PaymentUpdateInput':
          return PaymentUpdateInput.fromJson(value);
        case 'Plan':
          return Plan.fromJson(value);
        case 'PlanKey':
          return PlanKeyTypeTransformer().decode(value);
        case 'PlanList':
          return PlanList.fromJson(value);
        case 'Pledge':
          return Pledge.fromJson(value);
        case 'PledgeDetail':
          return PledgeDetail.fromJson(value);
        case 'PledgeStatus':
          return PledgeStatusTypeTransformer().decode(value);
        case 'PledgeUpdateInput':
          return PledgeUpdateInput.fromJson(value);
        case 'PublicCard':
          return PublicCard.fromJson(value);
        case 'PublicCardEvent':
          return PublicCardEvent.fromJson(value);
        case 'QueueStats':
          return QueueStats.fromJson(value);
        case 'QueueStatsList':
          return QueueStatsList.fromJson(value);
        case 'RetryAdminQueue200Response':
          return RetryAdminQueue200Response.fromJson(value);
        case 'Rsvp':
          return Rsvp.fromJson(value);
        case 'RsvpInput':
          return RsvpInput.fromJson(value);
        case 'SendManualMessage200Response':
          return SendManualMessage200Response.fromJson(value);
        case 'SendManualMessage202Response':
          return SendManualMessage202Response.fromJson(value);
        case 'SendManualMessageRequest':
          return SendManualMessageRequest.fromJson(value);
        case 'SendTestMessage202Response':
          return SendTestMessage202Response.fromJson(value);
        case 'SendTestMessageRequest':
          return SendTestMessageRequest.fromJson(value);
        case 'SetConfirmationRequest':
          return SetConfirmationRequest.fromJson(value);
        case 'SharingMode':
          return SharingModeTypeTransformer().decode(value);
        case 'Team':
          return Team.fromJson(value);
        case 'TeamMembersInner':
          return TeamMembersInner.fromJson(value);
        case 'TeamRole':
          return TeamRoleTypeTransformer().decode(value);
        case 'TotpCodeInput':
          return TotpCodeInput.fromJson(value);
        case 'TotpEnrolment':
          return TotpEnrolment.fromJson(value);
        case 'TotpRecoveryCodes':
          return TotpRecoveryCodes.fromJson(value);
        case 'TotpStatus':
          return TotpStatus.fromJson(value);
        case 'UpdateMessageSettingsRequest':
          return UpdateMessageSettingsRequest.fromJson(value);
        case 'UpdateMessageSettingsRequestSettingsInner':
          return UpdateMessageSettingsRequestSettingsInner.fromJson(value);
        case 'UpdateMessageSettingsRequestSettingsInnerSchedule':
          return UpdateMessageSettingsRequestSettingsInnerSchedule.fromJson(value);
        case 'UploadCompleteInput':
          return UploadCompleteInput.fromJson(value);
        case 'UploadSession':
          return UploadSession.fromJson(value);
        case 'UploadSessionInput':
          return UploadSessionInput.fromJson(value);
        case 'WalkIn':
          return WalkIn.fromJson(value);
        case 'WalkInConflict':
          return WalkInConflict.fromJson(value);
        case 'WalkInCreateInput':
          return WalkInCreateInput.fromJson(value);
        case 'WalkInDecisionInput':
          return WalkInDecisionInput.fromJson(value);
        case 'WalkInStatus':
          return WalkInStatusTypeTransformer().decode(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
