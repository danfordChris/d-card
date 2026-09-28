# dcard_api.model.Payment

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**kind** | **String** |  | 
**amount** | **int** | Signed: refunds are negative | 
**method** | [**PaymentMethod**](PaymentMethod.md) |  | 
**reference** | **String** |  | 
**paidOn** | [**DateTime**](DateTime.md) |  | 
**recordedBy** | **String** |  | 
**recordedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


