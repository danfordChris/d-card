# dcard_api.model.PaymentAttempt

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**status** | [**PaymentStatus**](PaymentStatus.md) |  | 
**method** | [**HostPaymentMethod**](HostPaymentMethod.md) |  | 
**amount** | **int** |  | 
**planKey** | [**PlanKey**](PlanKey.md) |  | 
**guestCards** | **int** |  | 
**phone** | **String** |  | 
**checkoutUrl** | **String** |  | 
**reference** | **String** |  | 
**failureReason** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**completedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


