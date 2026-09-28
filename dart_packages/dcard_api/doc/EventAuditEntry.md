# dcard_api.model.EventAuditEntry

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**action** | **String** |  | 
**actorType** | **String** |  | 
**actorName** | **String** |  | 
**targetType** | **String** |  | 
**targetId** | **String** |  | 
**changes** | [**List<AuditChange>**](AuditChange.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


