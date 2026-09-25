# dcard_api.model.PaymentCreateInput

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | **String** |  | [optional] 
**amount** | **int** | Positive; refunds are stored negative | 
**method** | [**PaymentMethod**](PaymentMethod.md) |  | 
**reference** | **String** |  | [optional] 
**paidOn** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


