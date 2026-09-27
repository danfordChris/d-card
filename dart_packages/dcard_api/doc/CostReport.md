# dcard_api.model.CostReport

## Load the model package
```dart
import 'package:dcard_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**from** | [**DateTime**](DateTime.md) |  | 
**to** | [**DateTime**](DateTime.md) |  | 
**feePercent** | **num** |  | 
**events** | [**List<CostReportEvent>**](CostReportEvent.md) |  | [default to const []]
**byPlan** | [**List<CostReportPlan>**](CostReportPlan.md) |  | [default to const []]
**byMonth** | [**List<CostReportMonth>**](CostReportMonth.md) |  | [default to const []]
**total** | [**CostLine**](CostLine.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


