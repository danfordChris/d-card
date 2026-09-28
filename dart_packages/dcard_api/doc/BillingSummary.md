# dcard_api.model.BillingSummary

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
**guestLimit** | **int** |  | 
**amountPaid** | **int** |  | 
**paid** | **bool** |  | 
**issuedCards** | **int** |  | 
**guestCount** | **int** |  | 
**launchOfferPercent** | **int** |  | 
**launchOfferEligible** | **bool** |  | 
**pendingAttempt** | [**PaymentAttempt**](PaymentAttempt.md) |  | 
**payments** | [**List<HostPayment>**](HostPayment.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


