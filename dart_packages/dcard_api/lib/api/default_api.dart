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

  /// Performs an HTTP 'POST /api/v1/admin/provider-rates' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [AdminCreateProviderRateRequest] adminCreateProviderRateRequest:
  Future<Response> adminCreateProviderRateWithHttpInfo({ AdminCreateProviderRateRequest? adminCreateProviderRateRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/provider-rates';

    // ignore: prefer_final_locals
    Object? postBody = adminCreateProviderRateRequest;

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
  /// * [AdminCreateProviderRateRequest] adminCreateProviderRateRequest:
  Future<AdminListProviderRates200ResponseRatesInner?> adminCreateProviderRate({ AdminCreateProviderRateRequest? adminCreateProviderRateRequest, }) async {
    final response = await adminCreateProviderRateWithHttpInfo( adminCreateProviderRateRequest: adminCreateProviderRateRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminListProviderRates200ResponseRatesInner',) as AdminListProviderRates200ResponseRatesInner;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/v1/admin/whatsapp-templates' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [AdminCreateWhatsappTemplateRequest] adminCreateWhatsappTemplateRequest:
  Future<Response> adminCreateWhatsappTemplateWithHttpInfo({ AdminCreateWhatsappTemplateRequest? adminCreateWhatsappTemplateRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/whatsapp-templates';

    // ignore: prefer_final_locals
    Object? postBody = adminCreateWhatsappTemplateRequest;

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
  /// * [AdminCreateWhatsappTemplateRequest] adminCreateWhatsappTemplateRequest:
  Future<AdminListWhatsappTemplates200ResponseTemplatesInner?> adminCreateWhatsappTemplate({ AdminCreateWhatsappTemplateRequest? adminCreateWhatsappTemplateRequest, }) async {
    final response = await adminCreateWhatsappTemplateWithHttpInfo( adminCreateWhatsappTemplateRequest: adminCreateWhatsappTemplateRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminListWhatsappTemplates200ResponseTemplatesInner',) as AdminListWhatsappTemplates200ResponseTemplatesInner;
    
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

  /// List effective-dated messaging provider rates (admin)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> adminListProviderRatesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/provider-rates';

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

  /// List effective-dated messaging provider rates (admin)
  Future<AdminListProviderRates200Response?> adminListProviderRates() async {
    final response = await adminListProviderRatesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminListProviderRates200Response',) as AdminListProviderRates200Response;
    
    }
    return null;
  }

  /// List all WhatsApp template variants (admin)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> adminListWhatsappTemplatesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/whatsapp-templates';

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

  /// List all WhatsApp template variants (admin)
  Future<AdminListWhatsappTemplates200Response?> adminListWhatsappTemplates() async {
    final response = await adminListWhatsappTemplatesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminListWhatsappTemplates200Response',) as AdminListWhatsappTemplates200Response;
    
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

  /// Update registration, Meta status or host availability
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AdminUpdateWhatsappTemplateRequest] adminUpdateWhatsappTemplateRequest:
  Future<Response> adminUpdateWhatsappTemplateWithHttpInfo(String id, { AdminUpdateWhatsappTemplateRequest? adminUpdateWhatsappTemplateRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/whatsapp-templates/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = adminUpdateWhatsappTemplateRequest;

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

  /// Update registration, Meta status or host availability
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [AdminUpdateWhatsappTemplateRequest] adminUpdateWhatsappTemplateRequest:
  Future<AdminListWhatsappTemplates200ResponseTemplatesInner?> adminUpdateWhatsappTemplate(String id, { AdminUpdateWhatsappTemplateRequest? adminUpdateWhatsappTemplateRequest, }) async {
    final response = await adminUpdateWhatsappTemplateWithHttpInfo(id,  adminUpdateWhatsappTemplateRequest: adminUpdateWhatsappTemplateRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminListWhatsappTemplates200ResponseTemplatesInner',) as AdminListWhatsappTemplates200ResponseTemplatesInner;
    
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

  /// Register the guest's Drive file after upload
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [UploadCompleteInput] uploadCompleteInput:
  Future<Response> completeGuestUploadWithHttpInfo(String token, String itemId, { UploadCompleteInput? uploadCompleteInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media/{itemId}/complete'
      .replaceAll('{token}', token)
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = uploadCompleteInput;

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

  /// Register the guest's Drive file after upload
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [UploadCompleteInput] uploadCompleteInput:
  Future<MediaItem?> completeGuestUpload(String token, String itemId, { UploadCompleteInput? uploadCompleteInput, }) async {
    final response = await completeGuestUploadWithHttpInfo(token, itemId,  uploadCompleteInput: uploadCompleteInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MediaItem',) as MediaItem;
    
    }
    return null;
  }

  /// Register the Drive file after the upload finished
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [UploadCompleteInput] uploadCompleteInput:
  Future<Response> completeHostUploadWithHttpInfo(String id, String itemId, { UploadCompleteInput? uploadCompleteInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/{itemId}/complete'
      .replaceAll('{id}', id)
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = uploadCompleteInput;

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

  /// Register the Drive file after the upload finished
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [UploadCompleteInput] uploadCompleteInput:
  Future<MediaItem?> completeHostUpload(String id, String itemId, { UploadCompleteInput? uploadCompleteInput, }) async {
    final response = await completeHostUploadWithHttpInfo(id, itemId,  uploadCompleteInput: uploadCompleteInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MediaItem',) as MediaItem;
    
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

  /// Redirects the host to Google consent (drive.file) for an event
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] eventId (required):
  Future<Response> connectGoogleDriveWithHttpInfo(String eventId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/media/google/connect';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'eventId', eventId));

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

  /// Redirects the host to Google consent (drive.file) for an event
  ///
  /// Parameters:
  ///
  /// * [String] eventId (required):
  Future<void> connectGoogleDrive(String eventId,) async {
    final response = await connectGoogleDriveWithHttpInfo(eventId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
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

  /// Guest gallery upload from the card link: Drive resumable URL within window and per-guest limits
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [UploadSessionInput] uploadSessionInput:
  Future<Response> createGuestUploadSessionWithHttpInfo(String token, { UploadSessionInput? uploadSessionInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media/upload-sessions'
      .replaceAll('{token}', token);

    // ignore: prefer_final_locals
    Object? postBody = uploadSessionInput;

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

  /// Guest gallery upload from the card link: Drive resumable URL within window and per-guest limits
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [UploadSessionInput] uploadSessionInput:
  Future<UploadSession?> createGuestUploadSession(String token, { UploadSessionInput? uploadSessionInput, }) async {
    final response = await createGuestUploadSessionWithHttpInfo(token,  uploadSessionInput: uploadSessionInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UploadSession',) as UploadSession;
    
    }
    return null;
  }

  /// Host upload (card or story): returns a Drive resumable URL within plan limits
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UploadSessionInput] uploadSessionInput:
  Future<Response> createHostUploadSessionWithHttpInfo(String id, { UploadSessionInput? uploadSessionInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/upload-sessions'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = uploadSessionInput;

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

  /// Host upload (card or story): returns a Drive resumable URL within plan limits
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UploadSessionInput] uploadSessionInput:
  Future<UploadSession?> createHostUploadSession(String id, { UploadSessionInput? uploadSessionInput, }) async {
    final response = await createHostUploadSessionWithHttpInfo(id,  uploadSessionInput: uploadSessionInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UploadSession',) as UploadSession;
    
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

  /// Approve/refuse a pending walk-in or accept/flag an offline one; the first answer wins
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] walkInId (required):
  ///
  /// * [WalkInDecisionInput] walkInDecisionInput:
  Future<Response> decideWalkInWithHttpInfo(String id, String walkInId, { WalkInDecisionInput? walkInDecisionInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/walk-ins/{walkInId}/decision'
      .replaceAll('{id}', id)
      .replaceAll('{walkInId}', walkInId);

    // ignore: prefer_final_locals
    Object? postBody = walkInDecisionInput;

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

  /// Approve/refuse a pending walk-in or accept/flag an offline one; the first answer wins
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] walkInId (required):
  ///
  /// * [WalkInDecisionInput] walkInDecisionInput:
  Future<WalkIn?> decideWalkIn(String id, String walkInId, { WalkInDecisionInput? walkInDecisionInput, }) async {
    final response = await decideWalkInWithHttpInfo(id, walkInId,  walkInDecisionInput: walkInDecisionInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WalkIn',) as WalkIn;
    
    }
    return null;
  }

  /// Delete an item (also deletes the Drive file D-Card created)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  Future<Response> deleteEventMediaWithHttpInfo(String id, String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/{itemId}'
      .replaceAll('{id}', id)
      .replaceAll('{itemId}', itemId);

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

  /// Delete an item (also deletes the Drive file D-Card created)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  Future<void> deleteEventMedia(String id, String itemId,) async {
    final response = await deleteEventMediaWithHttpInfo(id, itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Guest deletes their own upload
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  Future<Response> deleteGuestMediaWithHttpInfo(String token, String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media/{itemId}'
      .replaceAll('{token}', token)
      .replaceAll('{itemId}', itemId);

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

  /// Guest deletes their own upload
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  Future<void> deleteGuestMedia(String token, String itemId,) async {
    final response = await deleteGuestMediaWithHttpInfo(token, itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Disconnect Google Drive (files stay in the host's Drive)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> disconnectGoogleDriveWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/media/google';

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

  /// Disconnect Google Drive (files stay in the host's Drive)
  Future<void> disconnectGoogleDrive() async {
    final response = await disconnectGoogleDriveWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Admit 1 or 2 on a card, atomically (idempotent per entry id)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DoorEntryInput] doorEntryInput:
  Future<Response> doorAdmitWithHttpInfo({ DoorEntryInput? doorEntryInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/entries';

    // ignore: prefer_final_locals
    Object? postBody = doorEntryInput;

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

  /// Admit 1 or 2 on a card, atomically (idempotent per entry id)
  ///
  /// Parameters:
  ///
  /// * [DoorEntryInput] doorEntryInput:
  Future<DoorEntryResult?> doorAdmit({ DoorEntryInput? doorEntryInput, }) async {
    final response = await doorAdmitWithHttpInfo( doorEntryInput: doorEntryInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DoorEntryResult',) as DoorEntryResult;
    
    }
    return null;
  }

  /// The door polls its request for the decision
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] walkInId (required):
  ///
  /// * [String] deviceId (required):
  Future<Response> doorGetWalkInWithHttpInfo(String walkInId, String deviceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/walk-ins/{walkInId}'
      .replaceAll('{walkInId}', walkInId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'deviceId', deviceId));

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

  /// The door polls its request for the decision
  ///
  /// Parameters:
  ///
  /// * [String] walkInId (required):
  ///
  /// * [String] deviceId (required):
  Future<WalkIn?> doorGetWalkIn(String walkInId, String deviceId,) async {
    final response = await doorGetWalkInWithHttpInfo(walkInId, deviceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WalkIn',) as WalkIn;
    
    }
    return null;
  }

  /// Find a card by QR token, card number or name
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DoorLookupInput] doorLookupInput:
  Future<Response> doorLookupWithHttpInfo({ DoorLookupInput? doorLookupInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/lookup';

    // ignore: prefer_final_locals
    Object? postBody = doorLookupInput;

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

  /// Find a card by QR token, card number or name
  ///
  /// Parameters:
  ///
  /// * [DoorLookupInput] doorLookupInput:
  Future<DoorLookupResult?> doorLookup({ DoorLookupInput? doorLookupInput, }) async {
    final response = await doorLookupWithHttpInfo( doorLookupInput: doorLookupInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DoorLookupResult',) as DoorLookupResult;
    
    }
    return null;
  }

  /// Request approval for a walk-in; pushes to the host and walk-in approvers
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [WalkInCreateInput] walkInCreateInput:
  Future<Response> doorRequestWalkInWithHttpInfo({ WalkInCreateInput? walkInCreateInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/walk-ins';

    // ignore: prefer_final_locals
    Object? postBody = walkInCreateInput;

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

  /// Request approval for a walk-in; pushes to the host and walk-in approvers
  ///
  /// Parameters:
  ///
  /// * [WalkInCreateInput] walkInCreateInput:
  Future<WalkIn?> doorRequestWalkIn({ WalkInCreateInput? walkInCreateInput, }) async {
    final response = await doorRequestWalkInWithHttpInfo( walkInCreateInput: walkInCreateInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WalkIn',) as WalkIn;
    
    }
    return null;
  }

  /// Event cache for offline check-in: full without `since`, changes only with it
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [String] since:
  ///
  /// * [int] pending:
  Future<Response> doorSyncDownloadWithHttpInfo(String deviceId, { String? since, int? pending, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/sync';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'deviceId', deviceId));
    if (since != null) {
      queryParams.addAll(_queryParams('', 'since', since));
    }
    if (pending != null) {
      queryParams.addAll(_queryParams('', 'pending', pending));
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

  /// Event cache for offline check-in: full without `since`, changes only with it
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [String] since:
  ///
  /// * [int] pending:
  Future<DoorSyncSnapshot?> doorSyncDownload(String deviceId, { String? since, int? pending, }) async {
    final response = await doorSyncDownloadWithHttpInfo(deviceId,  since: since, pending: pending, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DoorSyncSnapshot',) as DoorSyncSnapshot;
    
    }
    return null;
  }

  /// Upload offline entries and attempts (idempotent; merges in any order)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DoorSyncUpload] doorSyncUpload:
  Future<Response> doorSyncUploadWithHttpInfo({ DoorSyncUpload? doorSyncUpload, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/sync';

    // ignore: prefer_final_locals
    Object? postBody = doorSyncUpload;

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

  /// Upload offline entries and attempts (idempotent; merges in any order)
  ///
  /// Parameters:
  ///
  /// * [DoorSyncUpload] doorSyncUpload:
  Future<DoorSyncResult?> doorSyncUpload({ DoorSyncUpload? doorSyncUpload, }) async {
    final response = await doorSyncUploadWithHttpInfo( doorSyncUpload: doorSyncUpload, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DoorSyncResult',) as DoorSyncResult;
    
    }
    return null;
  }

  /// Plan, paid guest cards, payments and any pending payment (host)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getBillingWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/billing'
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

  /// Plan, paid guest cards, payments and any pending payment (host)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<BillingSummary?> getBilling(String id,) async {
    final response = await getBillingWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BillingSummary',) as BillingSummary;
    
    }
    return null;
  }

  /// Launch offer setting (admin)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getBillingSettingsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/billing/settings';

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

  /// Launch offer setting (admin)
  Future<BillingSettings?> getBillingSettings() async {
    final response = await getBillingSettingsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BillingSettings',) as BillingSettings;
    
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

  /// Payment status (poll while pending)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] attemptId (required):
  Future<Response> getCheckoutWithHttpInfo(String id, String attemptId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/checkout/{attemptId}'
      .replaceAll('{id}', id)
      .replaceAll('{attemptId}', attemptId);

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

  /// Payment status (poll while pending)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] attemptId (required):
  Future<PaymentAttempt?> getCheckout(String id, String attemptId,) async {
    final response = await getCheckoutWithHttpInfo(id, attemptId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PaymentAttempt',) as PaymentAttempt;
    
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

  /// Private mode: streams the thumbnail or file for the host (?size=thumb|full)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] size:
  Future<Response> getEventMediaContentWithHttpInfo(String id, String itemId, { String? size, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/{itemId}/content'
      .replaceAll('{id}', id)
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (size != null) {
      queryParams.addAll(_queryParams('', 'size', size));
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

  /// Private mode: streams the thumbnail or file for the host (?size=thumb|full)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] size:
  Future<void> getEventMediaContent(String id, String itemId, { String? size, }) async {
    final response = await getEventMediaContentWithHttpInfo(id, itemId,  size: size, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Story and gallery for a card link (no login); upload window and the guest's remaining uploads
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> getGuestMediaWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media'
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

  /// Story and gallery for a card link (no login); upload window and the guest's remaining uploads
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<GuestMedia?> getGuestMedia(String token,) async {
    final response = await getGuestMediaWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GuestMedia',) as GuestMedia;
    
    }
    return null;
  }

  /// Private mode: streams a visible item for a valid card link (?size=thumb|full)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] size:
  Future<Response> getGuestMediaContentWithHttpInfo(String token, String itemId, { String? size, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media/{itemId}/content'
      .replaceAll('{token}', token)
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (size != null) {
      queryParams.addAll(_queryParams('', 'size', size));
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

  /// Private mode: streams a visible item for a valid card link (?size=thumb|full)
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] size:
  Future<void> getGuestMediaContent(String token, String itemId, { String? size, }) async {
    final response = await getGuestMediaContentWithHttpInfo(token, itemId,  size: size, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
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

  /// Drive connection, sharing mode, quota, plan limits and counts (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getMediaSettingsWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/settings'
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

  /// Drive connection, sharing mode, quota, plan limits and counts (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<MediaSettings?> getMediaSettings(String id,) async {
    final response = await getMediaSettingsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MediaSettings',) as MediaSettings;
    
    }
    return null;
  }

  /// Message settings for NTF-1…8 with the plan's limits (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> getMessageSettingsWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/messages'
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

  /// Message settings for NTF-1…8 with the plan's limits (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<MessageSettings?> getMessageSettings(String id,) async {
    final response = await getMessageSettingsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MessageSettings',) as MessageSettings;
    
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

  /// Confirmation states and expected headcount (host or committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> listConfirmationsWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/confirmations'
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

  /// Confirmation states and expected headcount (host or committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<ListConfirmations200Response?> listConfirmations(String id,) async {
    final response = await listConfirmationsWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListConfirmations200Response',) as ListConfirmations200Response;
    
    }
    return null;
  }

  /// Door devices of an event with last sync (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> listDoorDevicesWithHttpInfo(String id,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/door-devices'
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

  /// Door devices of an event with last sync (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<ListDoorDevices200Response?> listDoorDevices(String id,) async {
    final response = await listDoorDevicesWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListDoorDevices200Response',) as ListDoorDevices200Response;
    
    }
    return null;
  }

  /// Events the signed-in user can check guests in for (host, committee, door staff)
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listDoorEventsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/events';

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

  /// Events the signed-in user can check guests in for (host, committee, door staff)
  Future<ListDoorEvents200Response?> listDoorEvents() async {
    final response = await listDoorEventsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListDoorEvents200Response',) as ListDoorEvents200Response;
    
    }
    return null;
  }

  /// Media of an event for the host (all statuses except deleted)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MediaKind] kind:
  Future<Response> listEventMediaWithHttpInfo(String id, { MediaKind? kind, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (kind != null) {
      queryParams.addAll(_queryParams('', 'kind', kind));
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

  /// Media of an event for the host (all statuses except deleted)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MediaKind] kind:
  Future<ListEventMedia200Response?> listEventMedia(String id, { MediaKind? kind, }) async {
    final response = await listEventMediaWithHttpInfo(id,  kind: kind, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListEventMedia200Response',) as ListEventMedia200Response;
    
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

  /// Event message log (no costs) and WhatsApp opt-outs (host, committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] status:
  ///
  /// * [String] messageType:
  ///
  /// * [String] channel:
  ///
  /// * [String] q:
  ///
  /// * [String] before:
  ///
  /// * [int] limit:
  Future<Response> listMessageLogWithHttpInfo(String id, { String? status, String? messageType, String? channel, String? q, String? before, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/messages/log'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (messageType != null) {
      queryParams.addAll(_queryParams('', 'messageType', messageType));
    }
    if (channel != null) {
      queryParams.addAll(_queryParams('', 'channel', channel));
    }
    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }
    if (before != null) {
      queryParams.addAll(_queryParams('', 'before', before));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
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

  /// Event message log (no costs) and WhatsApp opt-outs (host, committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] status:
  ///
  /// * [String] messageType:
  ///
  /// * [String] channel:
  ///
  /// * [String] q:
  ///
  /// * [String] before:
  ///
  /// * [int] limit:
  Future<MessageLog?> listMessageLog(String id, { String? status, String? messageType, String? channel, String? q, String? before, int? limit, }) async {
    final response = await listMessageLogWithHttpInfo(id,  status: status, messageType: messageType, channel: channel, q: q, before: before, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MessageLog',) as MessageLog;
    
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

  /// Walk-ins of an event (host, committee, walk-in approvers)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [WalkInStatus] status:
  Future<Response> listWalkInsWithHttpInfo(String id, { WalkInStatus? status, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/walk-ins'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
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

  /// Walk-ins of an event (host, committee, walk-in approvers)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [WalkInStatus] status:
  Future<ListWalkIns200Response?> listWalkIns(String id, { WalkInStatus? status, }) async {
    final response = await listWalkInsWithHttpInfo(id,  status: status, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListWalkIns200Response',) as ListWalkIns200Response;
    
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

  /// Price for buying cards, adding blocks of 10 or upgrading (minimum charge, launch offer applied)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [BillingQuoteInput] billingQuoteInput:
  Future<Response> quoteBillingWithHttpInfo(String id, { BillingQuoteInput? billingQuoteInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/billing/quote'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = billingQuoteInput;

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

  /// Price for buying cards, adding blocks of 10 or upgrading (minimum charge, launch offer applied)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [BillingQuoteInput] billingQuoteInput:
  Future<BillingQuote?> quoteBilling(String id, { BillingQuoteInput? billingQuoteInput, }) async {
    final response = await quoteBillingWithHttpInfo(id,  billingQuoteInput: billingQuoteInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BillingQuote',) as BillingQuote;
    
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

  /// Register (upsert) this device's push token for the signed-in user
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DeviceRegisterInput] deviceRegisterInput:
  Future<Response> registerDeviceWithHttpInfo({ DeviceRegisterInput? deviceRegisterInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me/devices';

    // ignore: prefer_final_locals
    Object? postBody = deviceRegisterInput;

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

  /// Register (upsert) this device's push token for the signed-in user
  ///
  /// Parameters:
  ///
  /// * [DeviceRegisterInput] deviceRegisterInput:
  Future<Device?> registerDevice({ DeviceRegisterInput? deviceRegisterInput, }) async {
    final response = await registerDeviceWithHttpInfo( deviceRegisterInput: deviceRegisterInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Device',) as Device;
    
    }
    return null;
  }

  /// Register this device for one event (idempotent per deviceId)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [DoorDeviceRegisterInput] doorDeviceRegisterInput:
  Future<Response> registerDoorDeviceWithHttpInfo({ DoorDeviceRegisterInput? doorDeviceRegisterInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/door/devices';

    // ignore: prefer_final_locals
    Object? postBody = doorDeviceRegisterInput;

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

  /// Register this device for one event (idempotent per deviceId)
  ///
  /// Parameters:
  ///
  /// * [DoorDeviceRegisterInput] doorDeviceRegisterInput:
  Future<DoorDevice?> registerDoorDevice({ DoorDeviceRegisterInput? doorDeviceRegisterInput, }) async {
    final response = await registerDoorDeviceWithHttpInfo( doorDeviceRegisterInput: doorDeviceRegisterInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DoorDevice',) as DoorDevice;
    
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

  /// Report an item to the host
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  Future<Response> reportGuestMediaWithHttpInfo(String token, String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/cards/{token}/media/{itemId}/report'
      .replaceAll('{token}', token)
      .replaceAll('{itemId}', itemId);

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

  /// Report an item to the host
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  ///
  /// * [String] itemId (required):
  Future<void> reportGuestMedia(String token, String itemId,) async {
    final response = await reportGuestMediaWithHttpInfo(token, itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Revoke a door device (host); its next door call gets 403
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] deviceId (required):
  Future<Response> revokeDoorDeviceWithHttpInfo(String id, String deviceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/door-devices/{deviceId}'
      .replaceAll('{id}', id)
      .replaceAll('{deviceId}', deviceId);

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

  /// Revoke a door device (host); its next door call gets 403
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] deviceId (required):
  Future<void> revokeDoorDevice(String id, String deviceId,) async {
    final response = await revokeDoorDeviceWithHttpInfo(id, deviceId,);
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

  /// Send a message now to a guest group, or preview the recipient count (host)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [SendManualMessageRequest] sendManualMessageRequest:
  Future<Response> sendManualMessageWithHttpInfo(String id, { SendManualMessageRequest? sendManualMessageRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/messages/send'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = sendManualMessageRequest;

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

  /// Send a message now to a guest group, or preview the recipient count (host)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [SendManualMessageRequest] sendManualMessageRequest:
  Future<SendManualMessage200Response?> sendManualMessage(String id, { SendManualMessageRequest? sendManualMessageRequest, }) async {
    final response = await sendManualMessageWithHttpInfo(id,  sendManualMessageRequest: sendManualMessageRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SendManualMessage200Response',) as SendManualMessage200Response;
    
    }
    return null;
  }

  /// Send a message with sample values to the host's own phone (rate-limited)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] type (required):
  ///
  /// * [SendTestMessageRequest] sendTestMessageRequest:
  Future<Response> sendTestMessageWithHttpInfo(String id, String type, { SendTestMessageRequest? sendTestMessageRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/messages/{type}/test'
      .replaceAll('{id}', id)
      .replaceAll('{type}', type);

    // ignore: prefer_final_locals
    Object? postBody = sendTestMessageRequest;

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

  /// Send a message with sample values to the host's own phone (rate-limited)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] type (required):
  ///
  /// * [SendTestMessageRequest] sendTestMessageRequest:
  Future<SendTestMessage202Response?> sendTestMessage(String id, String type, { SendTestMessageRequest? sendTestMessageRequest, }) async {
    final response = await sendTestMessageWithHttpInfo(id, type,  sendTestMessageRequest: sendTestMessageRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SendTestMessage202Response',) as SendTestMessage202Response;
    
    }
    return null;
  }

  /// Record or override a guest confirmation (host or committee)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  ///
  /// * [SetConfirmationRequest] setConfirmationRequest:
  Future<Response> setConfirmationWithHttpInfo(String id, String guestId, { SetConfirmationRequest? setConfirmationRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/confirmations/{guestId}'
      .replaceAll('{id}', id)
      .replaceAll('{guestId}', guestId);

    // ignore: prefer_final_locals
    Object? postBody = setConfirmationRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Record or override a guest confirmation (host or committee)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] guestId (required):
  ///
  /// * [SetConfirmationRequest] setConfirmationRequest:
  Future<ListConfirmations200ResponseGuestsInner?> setConfirmation(String id, String guestId, { SetConfirmationRequest? setConfirmationRequest, }) async {
    final response = await setConfirmationWithHttpInfo(id, guestId,  setConfirmationRequest: setConfirmationRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListConfirmations200ResponseGuestsInner',) as ListConfirmations200ResponseGuestsInner;
    
    }
    return null;
  }

  /// Hide or show an item (host moderation, audited)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [MediaStatusInput] mediaStatusInput:
  Future<Response> setMediaStatusWithHttpInfo(String id, String itemId, { MediaStatusInput? mediaStatusInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/{itemId}'
      .replaceAll('{id}', id)
      .replaceAll('{itemId}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = mediaStatusInput;

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

  /// Hide or show an item (host moderation, audited)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] itemId (required):
  ///
  /// * [MediaStatusInput] mediaStatusInput:
  Future<MediaItem?> setMediaStatus(String id, String itemId, { MediaStatusInput? mediaStatusInput, }) async {
    final response = await setMediaStatusWithHttpInfo(id, itemId,  mediaStatusInput: mediaStatusInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MediaItem',) as MediaItem;
    
    }
    return null;
  }

  /// Start a Snippe payment: mobile-money push or hosted checkout session
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [CheckoutInput] checkoutInput:
  Future<Response> startCheckoutWithHttpInfo(String id, { CheckoutInput? checkoutInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/checkout'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = checkoutInput;

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

  /// Start a Snippe payment: mobile-money push or hosted checkout session
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [CheckoutInput] checkoutInput:
  Future<PaymentAttempt?> startCheckout(String id, { CheckoutInput? checkoutInput, }) async {
    final response = await startCheckoutWithHttpInfo(id,  checkoutInput: checkoutInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PaymentAttempt',) as PaymentAttempt;
    
    }
    return null;
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

  /// Remove a push token of the signed-in user (idempotent; call on sign-out)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<Response> unregisterDeviceWithHttpInfo(String token,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/me/devices/{token}'
      .replaceAll('{token}', token);

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

  /// Remove a push token of the signed-in user (idempotent; call on sign-out)
  ///
  /// Parameters:
  ///
  /// * [String] token (required):
  Future<void> unregisterDevice(String token,) async {
    final response = await unregisterDeviceWithHttpInfo(token,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Change or switch off the launch offer (admin, audited)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [BillingSettings] billingSettings:
  Future<Response> updateBillingSettingsWithHttpInfo({ BillingSettings? billingSettings, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/admin/billing/settings';

    // ignore: prefer_final_locals
    Object? postBody = billingSettings;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Change or switch off the launch offer (admin, audited)
  ///
  /// Parameters:
  ///
  /// * [BillingSettings] billingSettings:
  Future<BillingSettings?> updateBillingSettings({ BillingSettings? billingSettings, }) async {
    final response = await updateBillingSettingsWithHttpInfo( billingSettings: billingSettings, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BillingSettings',) as BillingSettings;
    
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

  /// Change sharing mode or the Google Photos link (host, audited)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MediaSettingsInput] mediaSettingsInput:
  Future<Response> updateMediaSettingsWithHttpInfo(String id, { MediaSettingsInput? mediaSettingsInput, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/media/settings'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = mediaSettingsInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Change sharing mode or the Google Photos link (host, audited)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [MediaSettingsInput] mediaSettingsInput:
  Future<MediaSettings?> updateMediaSettings(String id, { MediaSettingsInput? mediaSettingsInput, }) async {
    final response = await updateMediaSettingsWithHttpInfo(id,  mediaSettingsInput: mediaSettingsInput, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MediaSettings',) as MediaSettings;
    
    }
    return null;
  }

  /// Save all 8 message settings (host)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateMessageSettingsRequest] updateMessageSettingsRequest:
  Future<Response> updateMessageSettingsWithHttpInfo(String id, { UpdateMessageSettingsRequest? updateMessageSettingsRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/v1/events/{id}/messages'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = updateMessageSettingsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Save all 8 message settings (host)
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [UpdateMessageSettingsRequest] updateMessageSettingsRequest:
  Future<MessageSettings?> updateMessageSettings(String id, { UpdateMessageSettingsRequest? updateMessageSettingsRequest, }) async {
    final response = await updateMessageSettingsWithHttpInfo(id,  updateMessageSettingsRequest: updateMessageSettingsRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MessageSettings',) as MessageSettings;
    
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
