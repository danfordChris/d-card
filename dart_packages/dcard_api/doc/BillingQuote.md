# dcard_api.model.BillingQuote

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**planKey** | [**PlanKey**](PlanKey.md) |  | 
**planName** | **String** |  | 
**pricePerGuest** | **int** |  | 
**currentGuestCards** | **int** |  | 
**guestCards** | **int** |  | 
**blockSize** | **int** |  | 
**minimumCharge** | **int** |  | 
**lines** | [**List<BillingQuoteLine>**](BillingQuoteLine.md) |  | [default to const []]
**subtotal** | **int** |  | 
**discountPercent** | **int** |  | 
**discountAmount** | **int** |  | 
**total** | **int** |  | 
**payable** | **bool** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


