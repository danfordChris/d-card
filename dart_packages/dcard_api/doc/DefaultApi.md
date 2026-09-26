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
[**adminCreateProviderRate**](DefaultApi.md#admincreateproviderrate) | **POST** /api/v1/admin/provider-rates | 
[**adminCreateWhatsappTemplate**](DefaultApi.md#admincreatewhatsapptemplate) | **POST** /api/v1/admin/whatsapp-templates | 
[**adminListEventTypes**](DefaultApi.md#adminlisteventtypes) | **GET** /api/v1/admin/event-types | All event types, including inactive (admin)
[**adminListProviderRates**](DefaultApi.md#adminlistproviderrates) | **GET** /api/v1/admin/provider-rates | List effective-dated messaging provider rates (admin)
[**adminListWhatsappTemplates**](DefaultApi.md#adminlistwhatsapptemplates) | **GET** /api/v1/admin/whatsapp-templates | List all WhatsApp template variants (admin)
[**adminUpdateEventType**](DefaultApi.md#adminupdateeventtype) | **PATCH** /api/v1/admin/event-types/{key} | Rename or activate/deactivate (existing events keep their type)
[**adminUpdateWhatsappTemplate**](DefaultApi.md#adminupdatewhatsapptemplate) | **PATCH** /api/v1/admin/whatsapp-templates/{id} | Update registration, Meta status or host availability
[**cancelCard**](DefaultApi.md#cancelcard) | **POST** /api/v1/events/{id}/guests/{guestId}/cancel | Cancel the card (host). Payments are kept.
[**cancelEvent**](DefaultApi.md#cancelevent) | **POST** /api/v1/events/{id}/cancel | Cancel a draft or published event (host only)
[**confirmGuestImport**](DefaultApi.md#confirmguestimport) | **POST** /api/v1/events/{id}/imports/{jobId}/confirm | 
[**createEvent**](DefaultApi.md#createevent) | **POST** /api/v1/events | Create a draft event (caller becomes host)
[**createInvite**](DefaultApi.md#createinvite) | **POST** /api/v1/events/{id}/team/invites | Create a 7-day, single-use invite link; emails it when an email is given (host only)
[**decideWalkIn**](DefaultApi.md#decidewalkin) | **POST** /api/v1/events/{id}/walk-ins/{walkInId}/decision | Approve/refuse a pending walk-in or accept/flag an offline one; the first answer wins
[**doorAdmit**](DefaultApi.md#dooradmit) | **POST** /api/v1/door/entries | Admit 1 or 2 on a card, atomically (idempotent per entry id)
[**doorGetWalkIn**](DefaultApi.md#doorgetwalkin) | **GET** /api/v1/door/walk-ins/{walkInId} | The door polls its request for the decision
[**doorLookup**](DefaultApi.md#doorlookup) | **POST** /api/v1/door/lookup | Find a card by QR token, card number or name
[**doorRequestWalkIn**](DefaultApi.md#doorrequestwalkin) | **POST** /api/v1/door/walk-ins | Request approval for a walk-in; pushes to the host and walk-in approvers
[**doorSyncDownload**](DefaultApi.md#doorsyncdownload) | **GET** /api/v1/door/sync | Event cache for offline check-in: full without `since`, changes only with it
[**doorSyncUpload**](DefaultApi.md#doorsyncupload) | **POST** /api/v1/door/sync | Upload offline entries and attempts (idempotent; merges in any order)
[**getCardCalendar**](DefaultApi.md#getcardcalendar) | **GET** /api/v1/cards/{token}/calendar.ics | Calendar entry (text/calendar)
[**getCardLink**](DefaultApi.md#getcardlink) | **GET** /api/v1/events/{id}/guests/{guestId}/card | Card number and link (host, committee)
[**getContributions**](DefaultApi.md#getcontributions) | **GET** /api/v1/events/{id}/contributions | Totals and contributors (host, committee, treasurer)
[**getEvent**](DefaultApi.md#getevent) | **GET** /api/v1/events/{id} | 
[**getHealth**](DefaultApi.md#gethealth) | **GET** /api/v1/health | Service health
[**getInvite**](DefaultApi.md#getinvite) | **GET** /api/v1/invites/{token} | Public invite info for the accept page
[**getMe**](DefaultApi.md#getme) | **GET** /api/v1/me | Current account
[**getMessageSettings**](DefaultApi.md#getmessagesettings) | **GET** /api/v1/events/{id}/messages | Message settings for NTF-1…8 with the plan's limits (host, committee)
[**getPledge**](DefaultApi.md#getpledge) | **GET** /api/v1/events/{id}/pledges/{pledgeId} | 
[**getPublicCard**](DefaultApi.md#getpubliccard) | **GET** /api/v1/cards/{token} | Guest card by link token (public, no login)
[**getTeam**](DefaultApi.md#getteam) | **GET** /api/v1/events/{id}/team | Members and pending invites (host only)
[**issueCard**](DefaultApi.md#issuecard) | **POST** /api/v1/events/{id}/guests/{guestId}/issue | Issue the card directly (host). Pending only.
[**listDoorDevices**](DefaultApi.md#listdoordevices) | **GET** /api/v1/events/{id}/door-devices | Door devices of an event with last sync (host, committee)
[**listDoorEvents**](DefaultApi.md#listdoorevents) | **GET** /api/v1/door/events | Events the signed-in user can check guests in for (host, committee, door staff)
[**listEventTypes**](DefaultApi.md#listeventtypes) | **GET** /api/v1/event-types | Active event types
[**listEvents**](DefaultApi.md#listevents) | **GET** /api/v1/events | Events where the caller is host or team member
[**listGuests**](DefaultApi.md#listguests) | **GET** /api/v1/events/{id}/guests | Guests of an event, newest first (host, committee, treasurer)
[**listMessageLog**](DefaultApi.md#listmessagelog) | **GET** /api/v1/events/{id}/messages/log | Event message log (no costs) and WhatsApp opt-outs (host, committee)
[**listPlans**](DefaultApi.md#listplans) | **GET** /api/v1/plans | Active plans with price per guest and entitlements
[**listWalkIns**](DefaultApi.md#listwalkins) | **GET** /api/v1/events/{id}/walk-ins | Walk-ins of an event (host, committee, walk-in approvers)
[**previewCopyGuests**](DefaultApi.md#previewcopyguests) | **POST** /api/v1/events/{id}/imports/copy | Preview copying people from the caller's past event
[**previewGuestImport**](DefaultApi.md#previewguestimport) | **POST** /api/v1/events/{id}/imports | Upload .xlsx/.csv (field `file`, ≤ 2 MB, ≤ 5,000 rows) and get a validation report; nothing is written
[**provisionMe**](DefaultApi.md#provisionme) | **POST** /api/v1/me | Create the D-Card account for the signed-in Firebase user (idempotent)
[**recordPayment**](DefaultApi.md#recordpayment) | **POST** /api/v1/events/{id}/pledges/{pledgeId}/payments | Record a payment or refund (host, treasurer). Final payment issues the card.
[**registerDevice**](DefaultApi.md#registerdevice) | **POST** /api/v1/me/devices | Register (upsert) this device's push token for the signed-in user
[**registerDoorDevice**](DefaultApi.md#registerdoordevice) | **POST** /api/v1/door/devices | Register this device for one event (idempotent per deviceId)
[**reinstateCard**](DefaultApi.md#reinstatecard) | **POST** /api/v1/events/{id}/guests/{guestId}/reinstate | Reinstate a cancelled card (host): same number and tokens.
[**removeGuest**](DefaultApi.md#removeguest) | **DELETE** /api/v1/events/{id}/guests/{guestId} | 
[**removeMember**](DefaultApi.md#removemember) | **DELETE** /api/v1/events/{id}/team/members/{userId} | 
[**revokeDoorDevice**](DefaultApi.md#revokedoordevice) | **DELETE** /api/v1/events/{id}/door-devices/{deviceId} | Revoke a door device (host); its next door call gets 403
[**revokeInvite**](DefaultApi.md#revokeinvite) | **DELETE** /api/v1/events/{id}/team/invites/{inviteId} | 
[**sendManualMessage**](DefaultApi.md#sendmanualmessage) | **POST** /api/v1/events/{id}/messages/send | Send a message now to a guest group, or preview the recipient count (host)
[**sendTestMessage**](DefaultApi.md#sendtestmessage) | **POST** /api/v1/events/{id}/messages/{type}/test | Send a message with sample values to the host's own phone (rate-limited)
[**submitRsvp**](DefaultApi.md#submitrsvp) | **POST** /api/v1/cards/{token}/rsvp | RSVP Yes/No with dietary note (public); editable until the event starts
[**unregisterDevice**](DefaultApi.md#unregisterdevice) | **DELETE** /api/v1/me/devices/{token} | Remove a push token of the signed-in user (idempotent; call on sign-out)
[**updateEvent**](DefaultApi.md#updateevent) | **PATCH** /api/v1/events/{id} | Edit details, contact and settings (host only)
[**updateGuest**](DefaultApi.md#updateguest) | **PATCH** /api/v1/events/{id}/guests/{guestId} | 
[**updateMessageSettings**](DefaultApi.md#updatemessagesettings) | **PUT** /api/v1/events/{id}/messages | Save all 8 message settings (host)
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

# **adminCreateProviderRate**
> AdminListProviderRates200ResponseRatesInner adminCreateProviderRate(adminCreateProviderRateRequest)



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
final adminCreateProviderRateRequest = AdminCreateProviderRateRequest(); // AdminCreateProviderRateRequest | 

try {
    final result = api_instance.adminCreateProviderRate(adminCreateProviderRateRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminCreateProviderRate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminCreateProviderRateRequest** | [**AdminCreateProviderRateRequest**](AdminCreateProviderRateRequest.md)|  | [optional] 

### Return type

[**AdminListProviderRates200ResponseRatesInner**](AdminListProviderRates200ResponseRatesInner.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateWhatsappTemplate**
> AdminListWhatsappTemplates200ResponseTemplatesInner adminCreateWhatsappTemplate(adminCreateWhatsappTemplateRequest)



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
final adminCreateWhatsappTemplateRequest = AdminCreateWhatsappTemplateRequest(); // AdminCreateWhatsappTemplateRequest | 

try {
    final result = api_instance.adminCreateWhatsappTemplate(adminCreateWhatsappTemplateRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminCreateWhatsappTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminCreateWhatsappTemplateRequest** | [**AdminCreateWhatsappTemplateRequest**](AdminCreateWhatsappTemplateRequest.md)|  | [optional] 

### Return type

[**AdminListWhatsappTemplates200ResponseTemplatesInner**](AdminListWhatsappTemplates200ResponseTemplatesInner.md)

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

# **adminListProviderRates**
> AdminListProviderRates200Response adminListProviderRates()

List effective-dated messaging provider rates (admin)

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
    final result = api_instance.adminListProviderRates();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminListProviderRates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminListProviderRates200Response**](AdminListProviderRates200Response.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListWhatsappTemplates**
> AdminListWhatsappTemplates200Response adminListWhatsappTemplates()

List all WhatsApp template variants (admin)

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
    final result = api_instance.adminListWhatsappTemplates();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminListWhatsappTemplates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminListWhatsappTemplates200Response**](AdminListWhatsappTemplates200Response.md)

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

# **adminUpdateWhatsappTemplate**
> AdminListWhatsappTemplates200ResponseTemplatesInner adminUpdateWhatsappTemplate(id, adminUpdateWhatsappTemplateRequest)

Update registration, Meta status or host availability

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
final adminUpdateWhatsappTemplateRequest = AdminUpdateWhatsappTemplateRequest(); // AdminUpdateWhatsappTemplateRequest | 

try {
    final result = api_instance.adminUpdateWhatsappTemplate(id, adminUpdateWhatsappTemplateRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminUpdateWhatsappTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminUpdateWhatsappTemplateRequest** | [**AdminUpdateWhatsappTemplateRequest**](AdminUpdateWhatsappTemplateRequest.md)|  | [optional] 

### Return type

[**AdminListWhatsappTemplates200ResponseTemplatesInner**](AdminListWhatsappTemplates200ResponseTemplatesInner.md)

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

# **decideWalkIn**
> WalkIn decideWalkIn(id, walkInId, walkInDecisionInput)

Approve/refuse a pending walk-in or accept/flag an offline one; the first answer wins

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
final walkInId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final walkInDecisionInput = WalkInDecisionInput(); // WalkInDecisionInput | 

try {
    final result = api_instance.decideWalkIn(id, walkInId, walkInDecisionInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->decideWalkIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **walkInId** | **String**|  | 
 **walkInDecisionInput** | [**WalkInDecisionInput**](WalkInDecisionInput.md)|  | [optional] 

### Return type

[**WalkIn**](WalkIn.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorAdmit**
> DoorEntryResult doorAdmit(doorEntryInput)

Admit 1 or 2 on a card, atomically (idempotent per entry id)

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
final doorEntryInput = DoorEntryInput(); // DoorEntryInput | 

try {
    final result = api_instance.doorAdmit(doorEntryInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorAdmit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **doorEntryInput** | [**DoorEntryInput**](DoorEntryInput.md)|  | [optional] 

### Return type

[**DoorEntryResult**](DoorEntryResult.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorGetWalkIn**
> WalkIn doorGetWalkIn(walkInId, deviceId)

The door polls its request for the decision

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
final walkInId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.doorGetWalkIn(walkInId, deviceId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorGetWalkIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **walkInId** | **String**|  | 
 **deviceId** | **String**|  | 

### Return type

[**WalkIn**](WalkIn.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorLookup**
> DoorLookupResult doorLookup(doorLookupInput)

Find a card by QR token, card number or name

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
final doorLookupInput = DoorLookupInput(); // DoorLookupInput | 

try {
    final result = api_instance.doorLookup(doorLookupInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorLookup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **doorLookupInput** | [**DoorLookupInput**](DoorLookupInput.md)|  | [optional] 

### Return type

[**DoorLookupResult**](DoorLookupResult.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorRequestWalkIn**
> WalkIn doorRequestWalkIn(walkInCreateInput)

Request approval for a walk-in; pushes to the host and walk-in approvers

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
final walkInCreateInput = WalkInCreateInput(); // WalkInCreateInput | 

try {
    final result = api_instance.doorRequestWalkIn(walkInCreateInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorRequestWalkIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **walkInCreateInput** | [**WalkInCreateInput**](WalkInCreateInput.md)|  | [optional] 

### Return type

[**WalkIn**](WalkIn.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorSyncDownload**
> DoorSyncSnapshot doorSyncDownload(deviceId, since, pending)

Event cache for offline check-in: full without `since`, changes only with it

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
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final since = since_example; // String | 
final pending = 56; // int | 

try {
    final result = api_instance.doorSyncDownload(deviceId, since, pending);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorSyncDownload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**|  | 
 **since** | **String**|  | [optional] 
 **pending** | **int**|  | [optional] 

### Return type

[**DoorSyncSnapshot**](DoorSyncSnapshot.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **doorSyncUpload**
> DoorSyncResult doorSyncUpload(doorSyncUpload)

Upload offline entries and attempts (idempotent; merges in any order)

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
final doorSyncUpload = DoorSyncUpload(); // DoorSyncUpload | 

try {
    final result = api_instance.doorSyncUpload(doorSyncUpload);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->doorSyncUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **doorSyncUpload** | [**DoorSyncUpload**](DoorSyncUpload.md)|  | [optional] 

### Return type

[**DoorSyncResult**](DoorSyncResult.md)

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

# **getMessageSettings**
> MessageSettings getMessageSettings(id)

Message settings for NTF-1…8 with the plan's limits (host, committee)

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
    final result = api_instance.getMessageSettings(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getMessageSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MessageSettings**](MessageSettings.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

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

# **listDoorDevices**
> ListDoorDevices200Response listDoorDevices(id)

Door devices of an event with last sync (host, committee)

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
    final result = api_instance.listDoorDevices(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listDoorDevices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**ListDoorDevices200Response**](ListDoorDevices200Response.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDoorEvents**
> ListDoorEvents200Response listDoorEvents()

Events the signed-in user can check guests in for (host, committee, door staff)

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
    final result = api_instance.listDoorEvents();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listDoorEvents: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ListDoorEvents200Response**](ListDoorEvents200Response.md)

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

# **listMessageLog**
> MessageLog listMessageLog(id, status, messageType, channel, q, before, limit)

Event message log (no costs) and WhatsApp opt-outs (host, committee)

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
final messageType = messageType_example; // String | 
final channel = channel_example; // String | 
final q = q_example; // String | 
final before = before_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.listMessageLog(id, status, messageType, channel, q, before, limit);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listMessageLog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **status** | **String**|  | [optional] 
 **messageType** | **String**|  | [optional] 
 **channel** | **String**|  | [optional] 
 **q** | **String**|  | [optional] 
 **before** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**MessageLog**](MessageLog.md)

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

# **listWalkIns**
> ListWalkIns200Response listWalkIns(id, status)

Walk-ins of an event (host, committee, walk-in approvers)

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
final status = ; // WalkInStatus | 

try {
    final result = api_instance.listWalkIns(id, status);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->listWalkIns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **status** | [**WalkInStatus**](.md)|  | [optional] 

### Return type

[**ListWalkIns200Response**](ListWalkIns200Response.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

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

# **registerDevice**
> Device registerDevice(deviceRegisterInput)

Register (upsert) this device's push token for the signed-in user

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
final deviceRegisterInput = DeviceRegisterInput(); // DeviceRegisterInput | 

try {
    final result = api_instance.registerDevice(deviceRegisterInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->registerDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceRegisterInput** | [**DeviceRegisterInput**](DeviceRegisterInput.md)|  | [optional] 

### Return type

[**Device**](Device.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDoorDevice**
> DoorDevice registerDoorDevice(doorDeviceRegisterInput)

Register this device for one event (idempotent per deviceId)

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
final doorDeviceRegisterInput = DoorDeviceRegisterInput(); // DoorDeviceRegisterInput | 

try {
    final result = api_instance.registerDoorDevice(doorDeviceRegisterInput);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->registerDoorDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **doorDeviceRegisterInput** | [**DoorDeviceRegisterInput**](DoorDeviceRegisterInput.md)|  | [optional] 

### Return type

[**DoorDevice**](DoorDevice.md)

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

# **revokeDoorDevice**
> revokeDoorDevice(id, deviceId)

Revoke a door device (host); its next door call gets 403

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
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.revokeDoorDevice(id, deviceId);
} catch (e) {
    print('Exception when calling DefaultApi->revokeDoorDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **deviceId** | **String**|  | 

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

# **sendManualMessage**
> SendManualMessage200Response sendManualMessage(id, sendManualMessageRequest)

Send a message now to a guest group, or preview the recipient count (host)

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
final sendManualMessageRequest = SendManualMessageRequest(); // SendManualMessageRequest | 

try {
    final result = api_instance.sendManualMessage(id, sendManualMessageRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sendManualMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **sendManualMessageRequest** | [**SendManualMessageRequest**](SendManualMessageRequest.md)|  | [optional] 

### Return type

[**SendManualMessage200Response**](SendManualMessage200Response.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendTestMessage**
> SendTestMessage202Response sendTestMessage(id, type, sendTestMessageRequest)

Send a message with sample values to the host's own phone (rate-limited)

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
final type = type_example; // String | 
final sendTestMessageRequest = SendTestMessageRequest(); // SendTestMessageRequest | 

try {
    final result = api_instance.sendTestMessage(id, type, sendTestMessageRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sendTestMessage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **type** | **String**|  | 
 **sendTestMessageRequest** | [**SendTestMessageRequest**](SendTestMessageRequest.md)|  | [optional] 

### Return type

[**SendTestMessage202Response**](SendTestMessage202Response.md)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: application/json
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

# **unregisterDevice**
> unregisterDevice(token)

Remove a push token of the signed-in user (idempotent; call on sign-out)

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
    api_instance.unregisterDevice(token);
} catch (e) {
    print('Exception when calling DefaultApi->unregisterDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebaseIdToken](../README.md#firebaseIdToken), [apiKey](../README.md#apiKey)

### HTTP request headers

 - **Content-Type**: Not defined
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

# **updateMessageSettings**
> MessageSettings updateMessageSettings(id, updateMessageSettingsRequest)

Save all 8 message settings (host)

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
final updateMessageSettingsRequest = UpdateMessageSettingsRequest(); // UpdateMessageSettingsRequest | 

try {
    final result = api_instance.updateMessageSettings(id, updateMessageSettingsRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->updateMessageSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateMessageSettingsRequest** | [**UpdateMessageSettingsRequest**](UpdateMessageSettingsRequest.md)|  | [optional] 

### Return type

[**MessageSettings**](MessageSettings.md)

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

