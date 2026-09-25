//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/v1/invites/{token}/accept' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> acceptInviteWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invites/{token}/accept'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] token (required):
  Future<InviteAccepted?> acceptInvite(String token,) async {
    final response = await acceptInviteWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InviteAccepted',) as InviteAccepted;
    
    }
    return null;
  }

  /// Add a contributor with a pledge (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ContributorCreateInput] contributorCreateInput:
  Future<Response> addContributorWithHttpInfo(String id, { ContributorCreateInput? contributorCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/contributions'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = contributorCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add a contributor with a pledge (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ContributorCreateInput] contributorCreateInput:
  Future<ContributorCreateResponse?> addContributor(String id, { ContributorCreateInput? contributorCreateInput, }) async {
    final response = await addContributorWithHttpInfo(id,  contributorCreateInput: contributorCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ContributorCreateResponse',) as ContributorCreateResponse;
    
    }
    return null;
  }

  /// Add a guest (host, committee). Existing phone returns the existing invitation with 200.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [GuestCreateInput] guestCreateInput:
  Future<Response> addGuestWithHttpInfo(String id, { GuestCreateInput? guestCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = guestCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add a guest (host, committee). Existing phone returns the existing invitation with 200.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [GuestCreateInput] guestCreateInput:
  Future<GuestCreateResponse?> addGuest(String id, { GuestCreateInput? guestCreateInput, }) async {
    final response = await addGuestWithHttpInfo(id,  guestCreateInput: guestCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GuestCreateResponse',) as GuestCreateResponse;
    
    }
    return null;
  }

  /// Add up to 500 guests picked from phone contacts (host, committee). Invalid rows are reported, not fatal.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [GuestBulkInput] guestBulkInput:
  Future<Response> addGuestsBulkWithHttpInfo(String id, { GuestBulkInput? guestBulkInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/bulk'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = guestBulkInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add up to 500 guests picked from phone contacts (host, committee). Invalid rows are reported, not fatal.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [GuestBulkInput] guestBulkInput:
  Future<GuestBulkResponse?> addGuestsBulk(String id, { GuestBulkInput? guestBulkInput, }) async {
    final response = await addGuestsBulkWithHttpInfo(id,  guestBulkInput: guestBulkInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GuestBulkResponse',) as GuestBulkResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/admin/event-types' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [AdminEventTypeCreateInput] adminEventTypeCreateInput:
  Future<Response> adminCreateEventTypeWithHttpInfo({ AdminEventTypeCreateInput? adminEventTypeCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/event-types';

    // ignore: prefer_final_locals
    Object? postBody = adminEventTypeCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [AdminEventTypeCreateInput] adminEventTypeCreateInput:
  Future<AdminEventType?> adminCreateEventType({ AdminEventTypeCreateInput? adminEventTypeCreateInput, }) async {
    final response = await adminCreateEventTypeWithHttpInfo( adminEventTypeCreateInput: adminEventTypeCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminEventType',) as AdminEventType;
    
    }
    return null;
  }

  /// All event types, including inactive (admin)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> adminListEventTypesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/event-types';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// All event types, including inactive (admin)
  Future<AdminEventTypeList?> adminListEventTypes() async {
    final response = await adminListEventTypesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminEventTypeList',) as AdminEventTypeList;
    
    }
    return null;
  }

  /// Rename or activate/deactivate (existing events keep their type)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  ///
  /// * [AdminEventTypeUpdateInput] adminEventTypeUpdateInput:
  Future<Response> adminUpdateEventTypeWithHttpInfo(String key, { AdminEventTypeUpdateInput? adminEventTypeUpdateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/event-types/{key}'
      .replaceAll('{key}', key);

    // ignore: prefer_final_locals
    Object? postBody = adminEventTypeUpdateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Rename or activate/deactivate (existing events keep their type)
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  ///
  /// * [AdminEventTypeUpdateInput] adminEventTypeUpdateInput:
  Future<AdminEventType?> adminUpdateEventType(String key, { AdminEventTypeUpdateInput? adminEventTypeUpdateInput, }) async {
    final response = await adminUpdateEventTypeWithHttpInfo(key,  adminEventTypeUpdateInput: adminEventTypeUpdateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminEventType',) as AdminEventType;
    
    }
    return null;
  }

  /// Cancel the card (host). Payments are kept.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Response> cancelCardWithHttpInfo(String id, String guestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}/cancel'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Cancel the card (host). Payments are kept.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Card?> cancelCard(String id, String guestId,) async {
    final response = await cancelCardWithHttpInfo(id, guestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Card',) as Card;
    
    }
    return null;
  }

  /// Cancel a draft or published event (host only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> cancelEventWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/cancel'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Cancel a draft or published event (host only)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Event?> cancelEvent(String id,) async {
    final response = await cancelEventWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Event',) as Event;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/events/{id}/imports/{jobId}/confirm' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] jobId (required):
  ///
  /// * [ImportConfirmInput] importConfirmInput:
  Future<Response> confirmGuestImportWithHttpInfo(String id, String jobId, { ImportConfirmInput? importConfirmInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/imports/{jobId}/confirm'
      .replaceAll('{id}', id)
      .replaceAll('{jobId}', jobId);

    // ignore: prefer_final_locals
    Object? postBody = importConfirmInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] jobId (required):
  ///
  /// * [ImportConfirmInput] importConfirmInput:
  Future<ImportResult?> confirmGuestImport(String id, String jobId, { ImportConfirmInput? importConfirmInput, }) async {
    final response = await confirmGuestImportWithHttpInfo(id, jobId,  importConfirmInput: importConfirmInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ImportResult',) as ImportResult;
    
    }
    return null;
  }

  /// Create a draft event (caller becomes host)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [EventCreateInput] eventCreateInput:
  Future<Response> createEventWithHttpInfo({ EventCreateInput? eventCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events';

    // ignore: prefer_final_locals
    Object? postBody = eventCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create a draft event (caller becomes host)
  ///
  /// Parameters:
  ///
  /// * [EventCreateInput] eventCreateInput:
  Future<Event?> createEvent({ EventCreateInput? eventCreateInput, }) async {
    final response = await createEventWithHttpInfo( eventCreateInput: eventCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Event',) as Event;
    
    }
    return null;
  }

  /// Create a 7-day, single-use invite link; emails it when an email is given (host only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [InviteCreateInput] inviteCreateInput:
  Future<Response> createInviteWithHttpInfo(String id, { InviteCreateInput? inviteCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/team/invites'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = inviteCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create a 7-day, single-use invite link; emails it when an email is given (host only)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [InviteCreateInput] inviteCreateInput:
  Future<InviteCreateResponse?> createInvite(String id, { InviteCreateInput? inviteCreateInput, }) async {
    final response = await createInviteWithHttpInfo(id,  inviteCreateInput: inviteCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InviteCreateResponse',) as InviteCreateResponse;
    
    }
    return null;
  }

  /// Calendar entry (text/calendar)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> getCardCalendarWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/calendar.ics'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Calendar entry (text/calendar)
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<String?> getCardCalendar(String token,) async {
    final response = await getCardCalendarWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Card number and link (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Response> getCardLinkWithHttpInfo(String id, String guestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}/card'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Card number and link (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<CardLink?> getCardLink(String id, String guestId,) async {
    final response = await getCardLinkWithHttpInfo(id, guestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CardLink',) as CardLink;
    
    }
    return null;
  }

  /// Totals and contributors (host, committee, treasurer)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] status:
  ///
  /// * [String] q:
  Future<Response> getContributionsWithHttpInfo(String id, { String? status, String? q, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/contributions'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Totals and contributors (host, committee, treasurer)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] status:
  ///
  /// * [String] q:
  Future<Contributions?> getContributions(String id, { String? status, String? q, }) async {
    final response = await getContributionsWithHttpInfo(id,  status: status, q: q, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Contributions',) as Contributions;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/events/{id}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getEventWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Event?> getEvent(String id,) async {
    final response = await getEventWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Event',) as Event;
    
    }
    return null;
  }

  /// Service health
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getHealthWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/health';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Service health
  Future<HealthResponse?> getHealth() async {
    final response = await getHealthWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'HealthResponse',) as HealthResponse;
    
    }
    return null;
  }

  /// Public invite info for the accept page
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> getInviteWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/invites/{token}'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Public invite info for the accept page
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<InviteInfo?> getInvite(String token,) async {
    final response = await getInviteWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InviteInfo',) as InviteInfo;
    
    }
    return null;
  }

  /// Current account
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getMeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Current account
  Future<Account?> getMe() async {
    final response = await getMeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Account',) as Account;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/v1/events/{id}/pledges/{pledgeId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  Future<Response> getPledgeWithHttpInfo(String id, String pledgeId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/pledges/{pledgeId}'
      .replaceAll('{id}', id)
      .replaceAll('{pledgeId}', pledgeId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  Future<PledgeDetail?> getPledge(String id, String pledgeId,) async {
    final response = await getPledgeWithHttpInfo(id, pledgeId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PledgeDetail',) as PledgeDetail;
    
    }
    return null;
  }

  /// Guest card by link token (public, no login)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> getPublicCardWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Guest card by link token (public, no login)
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<PublicCard?> getPublicCard(String token,) async {
    final response = await getPublicCardWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PublicCard',) as PublicCard;
    
    }
    return null;
  }

  /// Members and pending invites (host only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getTeamWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/team'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Members and pending invites (host only)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Team?> getTeam(String id,) async {
    final response = await getTeamWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Team',) as Team;
    
    }
    return null;
  }

  /// Issue the card directly (host). Pending only.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Response> issueCardWithHttpInfo(String id, String guestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}/issue'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Issue the card directly (host). Pending only.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Card?> issueCard(String id, String guestId,) async {
    final response = await issueCardWithHttpInfo(id, guestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Card',) as Card;
    
    }
    return null;
  }

  /// Active event types
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listEventTypesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/event-types';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Active event types
  Future<EventTypeList?> listEventTypes() async {
    final response = await listEventTypesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EventTypeList',) as EventTypeList;
    
    }
    return null;
  }

  /// Events where the caller is host or team member
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listEventsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Events where the caller is host or team member
  Future<EventList?> listEvents() async {
    final response = await listEventsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EventList',) as EventList;
    
    }
    return null;
  }

  /// Guests of an event, newest first (host, committee, treasurer)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] q:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listGuestsWithHttpInfo(String id, { String? q, int? limit, String? cursor, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Guests of an event, newest first (host, committee, treasurer)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] q:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<GuestPage?> listGuests(String id, { String? q, int? limit, String? cursor, }) async {
    final response = await listGuestsWithHttpInfo(id,  q: q, limit: limit, cursor: cursor, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GuestPage',) as GuestPage;
    
    }
    return null;
  }

  /// Active plans with price per guest and entitlements
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPlansWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/plans';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Active plans with price per guest and entitlements
  Future<PlanList?> listPlans() async {
    final response = await listPlansWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PlanList',) as PlanList;
    
    }
    return null;
  }

  /// Preview copying people from the caller's past event
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ImportCopyInput] importCopyInput:
  Future<Response> previewCopyGuestsWithHttpInfo(String id, { ImportCopyInput? importCopyInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/imports/copy'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = importCopyInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Preview copying people from the caller's past event
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ImportCopyInput] importCopyInput:
  Future<ImportPreview?> previewCopyGuests(String id, { ImportCopyInput? importCopyInput, }) async {
    final response = await previewCopyGuestsWithHttpInfo(id,  importCopyInput: importCopyInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ImportPreview',) as ImportPreview;
    
    }
    return null;
  }

  /// Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MultipartFile] file (required):
  Future<Response> previewGuestImportWithHttpInfo(String id, MultipartFile file,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/imports'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['multipart/form-data'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(path));
    if (file != null) {
      hasFields = true;
      mp.fields[r'file'] = file.field;
      mp.files.add(file);
    }
    if (hasFields) {
      postBody = mp;
    }

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MultipartFile] file (required):
  Future<ImportPreview?> previewGuestImport(String id, MultipartFile file,) async {
    final response = await previewGuestImportWithHttpInfo(id, file,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ImportPreview',) as ImportPreview;
    
    }
    return null;
  }

  /// Create the D-Card account for the signed-in Firebase user (idempotent)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> provisionMeWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create the D-Card account for the signed-in Firebase user (idempotent)
  Future<Account?> provisionMe() async {
    final response = await provisionMeWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Account',) as Account;
    
    }
    return null;
  }

  /// Record a payment or refund (host, treasurer). Final payment issues the card.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  ///
  /// * [PaymentCreateInput] paymentCreateInput:
  Future<Response> recordPaymentWithHttpInfo(String id, String pledgeId, { PaymentCreateInput? paymentCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/pledges/{pledgeId}/payments'
      .replaceAll('{id}', id)
      .replaceAll('{pledgeId}', pledgeId);

    // ignore: prefer_final_locals
    Object? postBody = paymentCreateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Record a payment or refund (host, treasurer). Final payment issues the card.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  ///
  /// * [PaymentCreateInput] paymentCreateInput:
  Future<PaymentResult?> recordPayment(String id, String pledgeId, { PaymentCreateInput? paymentCreateInput, }) async {
    final response = await recordPaymentWithHttpInfo(id, pledgeId,  paymentCreateInput: paymentCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PaymentResult',) as PaymentResult;
    
    }
    return null;
  }

  /// Reinstate a cancelled card (host): same number and tokens.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Response> reinstateCardWithHttpInfo(String id, String guestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}/reinstate'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Reinstate a cancelled card (host): same number and tokens.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Card?> reinstateCard(String id, String guestId,) async {
    final response = await reinstateCardWithHttpInfo(id, guestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Card',) as Card;
    
    }
    return null;
  }

  /// Performs an HTTP 'DELETE /api/v1/events/{id}/guests/{guestId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<Response> removeGuestWithHttpInfo(String id, String guestId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  Future<void> removeGuest(String id, String guestId,) async {
    final response = await removeGuestWithHttpInfo(id, guestId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'DELETE /api/v1/events/{id}/team/members/{userId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] userId (required):
  ///
  /// * [TeamRole] role (required):
  Future<Response> removeMemberWithHttpInfo(String id, String userId, TeamRole role,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/team/members/{userId}'
      .replaceAll('{id}', id)
      .replaceAll('{userId}', userId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'role', role));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] userId (required):
  ///
  /// * [TeamRole] role (required):
  Future<void> removeMember(String id, String userId, TeamRole role,) async {
    final response = await removeMemberWithHttpInfo(id, userId, role,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'DELETE /api/v1/events/{id}/team/invites/{inviteId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] inviteId (required):
  Future<Response> revokeInviteWithHttpInfo(String id, String inviteId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/team/invites/{inviteId}'
      .replaceAll('{id}', id)
      .replaceAll('{inviteId}', inviteId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] inviteId (required):
  Future<void> revokeInvite(String id, String inviteId,) async {
    final response = await revokeInviteWithHttpInfo(id, inviteId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// RSVP Yes/No with dietary note (public); editable until the event starts
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [RsvpInput] rsvpInput:
  Future<Response> submitRsvpWithHttpInfo(String token, { RsvpInput? rsvpInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/rsvp'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody = rsvpInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// RSVP Yes/No with dietary note (public); editable until the event starts
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [RsvpInput] rsvpInput:
  Future<Rsvp?> submitRsvp(String token, { RsvpInput? rsvpInput, }) async {
    final response = await submitRsvpWithHttpInfo(token,  rsvpInput: rsvpInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Rsvp',) as Rsvp;
    
    }
    return null;
  }

  /// Edit details, contact and settings (host only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [EventUpdateInput] eventUpdateInput:
  Future<Response> updateEventWithHttpInfo(String id, { EventUpdateInput? eventUpdateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = eventUpdateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Edit details, contact and settings (host only)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [EventUpdateInput] eventUpdateInput:
  Future<Event?> updateEvent(String id, { EventUpdateInput? eventUpdateInput, }) async {
    final response = await updateEventWithHttpInfo(id,  eventUpdateInput: eventUpdateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Event',) as Event;
    
    }
    return null;
  }

  /// Performs an HTTP 'PATCH /api/v1/events/{id}/guests/{guestId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  ///
  /// * [GuestUpdateInput] guestUpdateInput:
  Future<Response> updateGuestWithHttpInfo(String id, String guestId, { GuestUpdateInput? guestUpdateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/guests/{guestId}'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody = guestUpdateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  ///
  /// * [GuestUpdateInput] guestUpdateInput:
  Future<Guest?> updateGuest(String id, String guestId, { GuestUpdateInput? guestUpdateInput, }) async {
    final response = await updateGuestWithHttpInfo(id, guestId,  guestUpdateInput: guestUpdateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Guest',) as Guest;
    
    }
    return null;
  }

  /// Correct a payment record (host, treasurer); audited
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] paymentId (required):
  ///
  /// * [PaymentUpdateInput] paymentUpdateInput:
  Future<Response> updatePaymentWithHttpInfo(String id, String paymentId, { PaymentUpdateInput? paymentUpdateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/payments/{paymentId}'
      .replaceAll('{id}', id)
      .replaceAll('{paymentId}', paymentId);

    // ignore: prefer_final_locals
    Object? postBody = paymentUpdateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Correct a payment record (host, treasurer); audited
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] paymentId (required):
  ///
  /// * [PaymentUpdateInput] paymentUpdateInput:
  Future<PaymentResult?> updatePayment(String id, String paymentId, { PaymentUpdateInput? paymentUpdateInput, }) async {
    final response = await updatePaymentWithHttpInfo(id, paymentId,  paymentUpdateInput: paymentUpdateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PaymentResult',) as PaymentResult;
    
    }
    return null;
  }

  /// Change amount/card type before issue (host, treasurer); issues if already covered
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  ///
  /// * [PledgeUpdateInput] pledgeUpdateInput:
  Future<Response> updatePledgeWithHttpInfo(String id, String pledgeId, { PledgeUpdateInput? pledgeUpdateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/pledges/{pledgeId}'
      .replaceAll('{id}', id)
      .replaceAll('{pledgeId}', pledgeId);

    // ignore: prefer_final_locals
    Object? postBody = pledgeUpdateInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Change amount/card type before issue (host, treasurer); issues if already covered
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] pledgeId (required):
  ///
  /// * [PledgeUpdateInput] pledgeUpdateInput:
  Future<Pledge?> updatePledge(String id, String pledgeId, { PledgeUpdateInput? pledgeUpdateInput, }) async {
    final response = await updatePledgeWithHttpInfo(id, pledgeId,  pledgeUpdateInput: pledgeUpdateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Pledge',) as Pledge;
    
    }
    return null;
  }
}
