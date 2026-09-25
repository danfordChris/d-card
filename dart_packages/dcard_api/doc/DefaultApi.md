# dcard_api.api.DefaultApi

## Load the API package
```dart
import 'package:dcard_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptInvite**](DefaultApi.md#acceptinvite) | **POST** /api/v1/invites/{token}/accept | 
[**addContributor**](DefaultApi.md#addcontributor) | **POST** /api/v1/events/{id}/contributions | Add a contributor with a pledge (host, committee)
[**addGuest**](DefaultApi.md#addguest) | **POST** /api/v1/events/{id}/guests | Add a guest (host, committee). Existing phone returns the existing invitation with 200.
[**addGuestsBulk**](DefaultApi.md#addguestsbulk) | **POST** /api/v1/events/{id}/guests/bulk | Add up to 500 guests picked from phone contacts (host, committee). Invalid rows are reported, not fatal.
[**adminCreateEventType**](DefaultApi.md#admincreateeventtype) | **POST** /api/v1/admin/event-types | 
[**adminListEventTypes**](DefaultApi.md#adminlisteventtypes) | **GET** /api/v1/admin/event-types | All event types, including inactive (admin)
[**adminUpdateEventType**](DefaultApi.md#adminupdateeventtype) | **PATCH** /api/v1/admin/event-types/{key} | Rename or activate/deactivate (existing events keep their type)
[**cancelCard**](DefaultApi.md#cancelcard) | **POST** /api/v1/events/{id}/guests/{guestId}/cancel | Cancel the card (host). Payments are kept.
[**cancelEvent**](DefaultApi.md#cancelevent) | **POST** /api/v1/events/{id}/cancel | Cancel a draft or published event (host only)
[**confirmGuestImport**](DefaultApi.md#confirmguestimport) | **POST** /api/v1/events/{id}/imports/{jobId}/confirm | 
[**createEvent**](DefaultApi.md#createevent) | **POST** /api/v1/events | Create a draft event (caller becomes host)
[**createInvite**](DefaultApi.md#createinvite) | **POST** /api/v1/events/{id}/team/invites | Create a 7-day, single-use invite link; emails it when an email is given (host only)
[**getCardCalendar**](DefaultApi.md#getcardcalendar) | **GET** /api/v1/cards/{token}/calendar.ics | Calendar entry (text/calendar)
[**getCardLink**](DefaultApi.md#getcardlink) | **GET** /api/v1/events/{id}/guests/{guestId}/card | Card number and link (host, committee)
[**getContributions**](DefaultApi.md#getcontributions) | **GET** /api/v1/events/{id}/contributions | Totals and contributors (host, committee, treasurer)
[**getEvent**](DefaultApi.md#getevent) | **GET** /api/v1/events/{id} | 
[**getHealth**](DefaultApi.md#gethealth) | **GET** /api/v1/health | Service health
[**getInvite**](DefaultApi.md#getinvite) | **GET** /api/v1/invites/{token} | Public invite info for the accept page
[**getMe**](DefaultApi.md#getme) | **GET** /api/v1/me | Current account
[**getPledge**](DefaultApi.md#getpledge) | **GET** /api/v1/events/{id}/pledges/{pledgeId} | 
[**getPublicCard**](DefaultApi.md#getpubliccard) | **GET** /api/v1/cards/{token} | Guest card by link token (public, no login)
[**getTeam**](DefaultApi.md#getteam) | **GET** /api/v1/events/{id}/team | Members and pending invites (host only)
[**issueCard**](DefaultApi.md#issuecard) | **POST** /api/v1/events/{id}/guests/{guestId}/issue | Issue the card directly (host). Pending only.
[**listEventTypes**](DefaultApi.md#listeventtypes) | **GET** /api/v1/event-types | Active event types
[**listEvents**](DefaultApi.md#listevents) | **GET** /api/v1/events | Events where the caller is host or team member
[**listGuests**](DefaultApi.md#listguests) | **GET** /api/v1/events/{id}/guests | Guests of an event, newest first (host, committee, treasurer)
[**listPlans**](DefaultApi.md#listplans) | **GET** /api/v1/plans | Active plans with price per guest and entitlements
[**previewCopyGuests**](DefaultApi.md#previewcopyguests) | **POST** /api/v1/events/{id}/imports/copy | Preview copying people from the caller's past event
[**previewGuestImport**](DefaultApi.md#previewguestimport) | **POST** /api/v1/events/{id}/imports | Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written
[**provisionMe**](DefaultApi.md#provisionme) | **POST** /api/v1/me | Create the D-Card account for the signed-in Firebase user (idempotent)
[**recordPayment**](DefaultApi.md#recordpayment) | **POST** /api/v1/events/{id}/pledges/{pledgeId}/payments | Record a payment or refund (host, treasurer). Final payment issues the card.
[**reinstateCard**](DefaultApi.md#reinstatecard) | **POST** /api/v1/events/{id}/guests/{guestId}/reinstate | Reinstate a cancelled card (host): same number and tokens.
[**removeGuest**](DefaultApi.md#removeguest) | **DELETE** /api/v1/events/{id}/guests/{guestId} | 
[**removeMember**](DefaultApi.md#removemember) | **DELETE** /api/v1/events/{id}/team/members/{userId} | 
[**revokeInvite**](DefaultApi.md#revokeinvite) | **DELETE** /api/v1/events/{id}/team/invites/{inviteId} | 
[**submitRsvp**](DefaultApi.md#submitrsvp) | **POST** /api/v1/cards/{token}/rsvp | RSVP Yes/No with dietary note (public); editable until the event starts
[**updateEvent**](DefaultApi.md#updateevent) | **PATCH** /api/v1/events/{id} | Edit details, contact and settings (host only)
[**updateGuest**](DefaultApi.md#updateguest) | **PATCH** /api/v1/events/{id}/guests/{guestId} | 
[**updatePayment**](DefaultApi.md#updatepayment) | **PATCH** /api/v1/events/{id}/payments/{paymentId} | Correct a payment record (host, treasurer); audited
[**updatePledge**](DefaultApi.md#updatepledge) | **PATCH** /api/v1/events/{id}/pledges/{pledgeId} | Change amount/card type before issue (host, treasurer); issues if already covered


# **acceptInvite**
> InviteAccepted acceptInvite(token)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final token = token_example; // String | 

try {
    final result = api_instance.acceptInvite(token);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->acceptInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**InviteAccepted**](InviteAccepted.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addContributor**
> ContributorCreateResponse addContributor(id, contributorCreateInput)

Add a contributor with a pledge (host, committee)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final contributorCreateInput = ContributorCreateInput(); // ContributorCreateInput | 

try {
    final result = api_instance.addContributor(id, contributorCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->addContributor: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **contributorCreateInput** | [**ContributorCreateInput**](ContributorCreateInput.md)|  | [optional] 

### Return type

[**ContributorCreateResponse**](ContributorCreateResponse.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addGuest**
> GuestCreateResponse addGuest(id, guestCreateInput)

Add a guest (host, committee). Existing phone returns the existing invitation with 200.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestCreateInput = GuestCreateInput(); // GuestCreateInput | 

try {
    final result = api_instance.addGuest(id, guestCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->addGuest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestCreateInput** | [**GuestCreateInput**](GuestCreateInput.md)|  | [optional] 

### Return type

[**GuestCreateResponse**](GuestCreateResponse.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **addGuestsBulk**
> GuestBulkResponse addGuestsBulk(id, guestBulkInput)

Add up to 500 guests picked from phone contacts (host, committee). Invalid rows are reported, not fatal.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestBulkInput = GuestBulkInput(); // GuestBulkInput | 

try {
    final result = api_instance.addGuestsBulk(id, guestBulkInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->addGuestsBulk: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestBulkInput** | [**GuestBulkInput**](GuestBulkInput.md)|  | [optional] 

### Return type

[**GuestBulkResponse**](GuestBulkResponse.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateEventType**
> AdminEventType adminCreateEventType(adminEventTypeCreateInput)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final adminEventTypeCreateInput = AdminEventTypeCreateInput(); // AdminEventTypeCreateInput | 

try {
    final result = api_instance.adminCreateEventType(adminEventTypeCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminCreateEventType: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminEventTypeCreateInput** | [**AdminEventTypeCreateInput**](AdminEventTypeCreateInput.md)|  | [optional] 

### Return type

[**AdminEventType**](AdminEventType.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListEventTypes**
> AdminEventTypeList adminListEventTypes()

All event types, including inactive (admin)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();

try {
    final result = api_instance.adminListEventTypes();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminListEventTypes: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminEventTypeList**](AdminEventTypeList.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateEventType**
> AdminEventType adminUpdateEventType(key, adminEventTypeUpdateInput)

Rename or activate/deactivate (existing events keep their type)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final key = key_example; // String | 
final adminEventTypeUpdateInput = AdminEventTypeUpdateInput(); // AdminEventTypeUpdateInput | 

try {
    final result = api_instance.adminUpdateEventType(key, adminEventTypeUpdateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminUpdateEventType: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **adminEventTypeUpdateInput** | [**AdminEventTypeUpdateInput**](AdminEventTypeUpdateInput.md)|  | [optional] 

### Return type

[**AdminEventType**](AdminEventType.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelCard**
> Card cancelCard(id, guestId)

Cancel the card (host). Payments are kept.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.cancelCard(id, guestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->cancelCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 

### Return type

[**Card**](Card.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelEvent**
> Event cancelEvent(id)

Cancel a draft or published event (host only)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.cancelEvent(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->cancelEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Event**](Event.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmGuestImport**
> ImportResult confirmGuestImport(id, jobId, importConfirmInput)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final importConfirmInput = ImportConfirmInput(); // ImportConfirmInput | 

try {
    final result = api_instance.confirmGuestImport(id, jobId, importConfirmInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->confirmGuestImport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **jobId** | **String**|  | 
 **importConfirmInput** | [**ImportConfirmInput**](ImportConfirmInput.md)|  | [optional] 

### Return type

[**ImportResult**](ImportResult.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEvent**
> Event createEvent(eventCreateInput)

Create a draft event (caller becomes host)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final eventCreateInput = EventCreateInput(); // EventCreateInput | 

try {
    final result = api_instance.createEvent(eventCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eventCreateInput** | [**EventCreateInput**](EventCreateInput.md)|  | [optional] 

### Return type

[**Event**](Event.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInvite**
> InviteCreateResponse createInvite(id, inviteCreateInput)

Create a 7-day, single-use invite link; emails it when an email is given (host only)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final inviteCreateInput = InviteCreateInput(); // InviteCreateInput | 

try {
    final result = api_instance.createInvite(id, inviteCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->createInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **inviteCreateInput** | [**InviteCreateInput**](InviteCreateInput.md)|  | [optional] 

### Return type

[**InviteCreateResponse**](InviteCreateResponse.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCardCalendar**
> String getCardCalendar(token)

Calendar entry (text/calendar)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final token = token_example; // String | 

try {
    final result = api_instance.getCardCalendar(token);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getCardCalendar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

**String**

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/calendar, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCardLink**
> CardLink getCardLink(id, guestId)

Card number and link (host, committee)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getCardLink(id, guestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getCardLink: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 

### Return type

[**CardLink**](CardLink.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContributions**
> Contributions getContributions(id, status, q)

Totals and contributors (host, committee, treasurer)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final status = status_example; // String | 
final q = q_example; // String | 

try {
    final result = api_instance.getContributions(id, status, q);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getContributions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **status** | **String**|  | [optional] 
 **q** | **String**|  | [optional] 

### Return type

[**Contributions**](Contributions.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEvent**
> Event getEvent(id)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getEvent(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Event**](Event.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealth**
> HealthResponse getHealth()

Service health

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();

try {
    final result = api_instance.getHealth();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvite**
> InviteInfo getInvite(token)

Public invite info for the accept page

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final token = token_example; // String | 

try {
    final result = api_instance.getInvite(token);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**InviteInfo**](InviteInfo.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> Account getMe()

Current account

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.getMe();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Account**](Account.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPledge**
> PledgeDetail getPledge(id, pledgeId)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final pledgeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getPledge(id, pledgeId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getPledge: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **pledgeId** | **String**|  | 

### Return type

[**PledgeDetail**](PledgeDetail.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPublicCard**
> PublicCard getPublicCard(token)

Guest card by link token (public, no login)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final token = token_example; // String | 

try {
    final result = api_instance.getPublicCard(token);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getPublicCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**PublicCard**](PublicCard.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeam**
> Team getTeam(id)

Members and pending invites (host only)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getTeam(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getTeam: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Team**](Team.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issueCard**
> Card issueCard(id, guestId)

Issue the card directly (host). Pending only.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.issueCard(id, guestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->issueCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 

### Return type

[**Card**](Card.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEventTypes**
> EventTypeList listEventTypes()

Active event types

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();

try {
    final result = api_instance.listEventTypes();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listEventTypes: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EventTypeList**](EventTypeList.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEvents**
> EventList listEvents()

Events where the caller is host or team member

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();

try {
    final result = api_instance.listEvents();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listEvents: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EventList**](EventList.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGuests**
> GuestPage listGuests(id, q, limit, cursor)

Guests of an event, newest first (host, committee, treasurer)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final q = q_example; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listGuests(id, q, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listGuests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **q** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 

### Return type

[**GuestPage**](GuestPage.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlans**
> PlanList listPlans()

Active plans with price per guest and entitlements

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();

try {
    final result = api_instance.listPlans();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listPlans: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PlanList**](PlanList.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewCopyGuests**
> ImportPreview previewCopyGuests(id, importCopyInput)

Preview copying people from the caller's past event

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final importCopyInput = ImportCopyInput(); // ImportCopyInput | 

try {
    final result = api_instance.previewCopyGuests(id, importCopyInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->previewCopyGuests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **importCopyInput** | [**ImportCopyInput**](ImportCopyInput.md)|  | [optional] 

### Return type

[**ImportPreview**](ImportPreview.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewGuestImport**
> ImportPreview previewGuestImport(id, file)

Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final file = BINARY_DATA_HERE; // MultipartFile | 

try {
    final result = api_instance.previewGuestImport(id, file);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->previewGuestImport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **file** | **MultipartFile**|  | 

### Return type

[**ImportPreview**](ImportPreview.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **provisionMe**
> Account provisionMe()

Create the D-Card account for the signed-in Firebase user (idempotent)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DefaultApi();

try {
    final result = api_instance.provisionMe();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->provisionMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Account**](Account.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordPayment**
> PaymentResult recordPayment(id, pledgeId, paymentCreateInput)

Record a payment or refund (host, treasurer). Final payment issues the card.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final pledgeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final paymentCreateInput = PaymentCreateInput(); // PaymentCreateInput | 

try {
    final result = api_instance.recordPayment(id, pledgeId, paymentCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->recordPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **pledgeId** | **String**|  | 
 **paymentCreateInput** | [**PaymentCreateInput**](PaymentCreateInput.md)|  | [optional] 

### Return type

[**PaymentResult**](PaymentResult.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reinstateCard**
> Card reinstateCard(id, guestId)

Reinstate a cancelled card (host): same number and tokens.

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.reinstateCard(id, guestId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->reinstateCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 

### Return type

[**Card**](Card.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeGuest**
> removeGuest(id, guestId)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.removeGuest(id, guestId);
} catch (e) {
    print('Exception when calling DefaultApi->removeGuest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeMember**
> removeMember(id, userId, role)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final role = ; // TeamRole | 

try {
    api_instance.removeMember(id, userId, role);
} catch (e) {
    print('Exception when calling DefaultApi->removeMember: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **userId** | **String**|  | 
 **role** | [**TeamRole**](.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeInvite**
> revokeInvite(id, inviteId)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final inviteId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.revokeInvite(id, inviteId);
} catch (e) {
    print('Exception when calling DefaultApi->revokeInvite: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **inviteId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitRsvp**
> Rsvp submitRsvp(token, rsvpInput)

RSVP Yes/No with dietary note (public); editable until the event starts

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final token = token_example; // String | 
final rsvpInput = RsvpInput(); // RsvpInput | 

try {
    final result = api_instance.submitRsvp(token, rsvpInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->submitRsvp: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 
 **rsvpInput** | [**RsvpInput**](RsvpInput.md)|  | [optional] 

### Return type

[**Rsvp**](Rsvp.md)

### Authorization

[apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEvent**
> Event updateEvent(id, eventUpdateInput)

Edit details, contact and settings (host only)

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final eventUpdateInput = EventUpdateInput(); // EventUpdateInput | 

try {
    final result = api_instance.updateEvent(id, eventUpdateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updateEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **eventUpdateInput** | [**EventUpdateInput**](EventUpdateInput.md)|  | [optional] 

### Return type

[**Event**](Event.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGuest**
> Guest updateGuest(id, guestId, guestUpdateInput)



### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final guestUpdateInput = GuestUpdateInput(); // GuestUpdateInput | 

try {
    final result = api_instance.updateGuest(id, guestId, guestUpdateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updateGuest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **guestId** | **String**|  | 
 **guestUpdateInput** | [**GuestUpdateInput**](GuestUpdateInput.md)|  | [optional] 

### Return type

[**Guest**](Guest.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePayment**
> PaymentResult updatePayment(id, paymentId, paymentUpdateInput)

Correct a payment record (host, treasurer); audited

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final paymentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final paymentUpdateInput = PaymentUpdateInput(); // PaymentUpdateInput | 

try {
    final result = api_instance.updatePayment(id, paymentId, paymentUpdateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updatePayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **paymentId** | **String**|  | 
 **paymentUpdateInput** | [**PaymentUpdateInput**](PaymentUpdateInput.md)|  | [optional] 

### Return type

[**PaymentResult**](PaymentResult.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePledge**
> Pledge updatePledge(id, pledgeId, pledgeUpdateInput)

Change amount/card type before issue (host, treasurer); issues if already covered

### Example
```dart
import 'package:dcard_api/api.dart';
// TODO Configure HTTP Bearer authorization: firebaseIdToken
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('firebaseIdToken').setAccessToken(yourTokenGeneratorFunction);
// TODO Configure API key authorization: apiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('apiKey').apiKeyPrefix = 'Bearer';

final api_instance = DefaultApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final pledgeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final pledgeUpdateInput = PledgeUpdateInput(); // PledgeUpdateInput | 

try {
    final result = api_instance.updatePledge(id, pledgeId, pledgeUpdateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updatePledge: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **pledgeId** | **String**|  | 
 **pledgeUpdateInput** | [**PledgeUpdateInput**](PledgeUpdateInput.md)|  | [optional] 

### Return type

[**Pledge**](Pledge.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

