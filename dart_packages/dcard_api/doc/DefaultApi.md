# dcard_api.api.DefaultApi

## Load the API package
```dart
import 'package:dcard_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getHealth**](DefaultApi.md#gethealth) | **GET** /api/v1/health | Service health
[**getMe**](DefaultApi.md#getme) | **GET** /api/v1/me | Current account
[**provisionMe**](DefaultApi.md#provisionme) | **POST** /api/v1/me | Create the D-Card account for the signed-in Firebase user (idempotent)


# **getHealth**
> HealthResponse getHealth()

Service health

### Example
```dart
import 'package:dcard_api/api.dart';

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

No authorization required

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

