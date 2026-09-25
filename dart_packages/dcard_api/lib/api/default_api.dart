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
}
