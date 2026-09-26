//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library dcard_api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/default_api.dart';

part 'model/account.dart';
part 'model/admin_create_provider_rate_request.dart';
part 'model/admin_create_whatsapp_template_request.dart';
part 'model/admin_event_type.dart';
part 'model/admin_event_type_create_input.dart';
part 'model/admin_event_type_list.dart';
part 'model/admin_event_type_update_input.dart';
part 'model/admin_list_provider_rates200_response.dart';
part 'model/admin_list_provider_rates200_response_rates_inner.dart';
part 'model/admin_list_whatsapp_templates200_response.dart';
part 'model/admin_list_whatsapp_templates200_response_templates_inner.dart';
part 'model/admin_update_whatsapp_template_request.dart';
part 'model/auth_provider.dart';
part 'model/card.dart';
part 'model/card_link.dart';
part 'model/card_type.dart';
part 'model/check_in_method.dart';
part 'model/contributions.dart';
part 'model/contributions_summary.dart';
part 'model/contributions_summary_counts.dart';
part 'model/contributor_create_input.dart';
part 'model/contributor_create_response.dart';
part 'model/device.dart';
part 'model/device_app.dart';
part 'model/device_platform.dart';
part 'model/device_register_input.dart';
part 'model/door_card.dart';
part 'model/door_device.dart';
part 'model/door_device_register_input.dart';
part 'model/door_entry.dart';
part 'model/door_entry_input.dart';
part 'model/door_entry_result.dart';
part 'model/door_event.dart';
part 'model/door_lookup_input.dart';
part 'model/door_lookup_result.dart';
part 'model/door_refusal.dart';
part 'model/door_refusal_card.dart';
part 'model/door_refusal_error.dart';
part 'model/door_sync_attempt_input.dart';
part 'model/door_sync_card.dart';
part 'model/door_sync_entry_input.dart';
part 'model/door_sync_result.dart';
part 'model/door_sync_snapshot.dart';
part 'model/door_sync_snapshot_approvers_inner.dart';
part 'model/door_sync_upload.dart';
part 'model/error_response.dart';
part 'model/error_response_error.dart';
part 'model/error_response_error_issues_inner.dart';
part 'model/event.dart';
part 'model/event_create_input.dart';
part 'model/event_list.dart';
part 'model/event_plan.dart';
part 'model/event_type.dart';
part 'model/event_type_list.dart';
part 'model/event_update_input.dart';
part 'model/guest.dart';
part 'model/guest_bulk_input.dart';
part 'model/guest_bulk_input_guests_inner.dart';
part 'model/guest_bulk_response.dart';
part 'model/guest_bulk_response_invalid_inner.dart';
part 'model/guest_create_input.dart';
part 'model/guest_create_response.dart';
part 'model/guest_page.dart';
part 'model/guest_update_input.dart';
part 'model/health_response.dart';
part 'model/import_confirm_input.dart';
part 'model/import_copy_input.dart';
part 'model/import_preview.dart';
part 'model/import_report.dart';
part 'model/import_report_duplicates_in_file_inner.dart';
part 'model/import_report_existing_inner.dart';
part 'model/import_report_invalid_inner.dart';
part 'model/import_result.dart';
part 'model/invite.dart';
part 'model/invite_accepted.dart';
part 'model/invite_create_input.dart';
part 'model/invite_create_response.dart';
part 'model/invite_info.dart';
part 'model/list_door_devices200_response.dart';
part 'model/list_door_events200_response.dart';
part 'model/list_walk_ins200_response.dart';
part 'model/message_log.dart';
part 'model/message_log_items_inner.dart';
part 'model/message_log_opt_outs_inner.dart';
part 'model/message_plan_limits.dart';
part 'model/message_settings.dart';
part 'model/message_settings_settings_inner.dart';
part 'model/message_settings_templates_inner.dart';
part 'model/message_settings_usage.dart';
part 'model/offline_walk_in_input.dart';
part 'model/payment.dart';
part 'model/payment_create_input.dart';
part 'model/payment_method.dart';
part 'model/payment_result.dart';
part 'model/payment_update_input.dart';
part 'model/plan.dart';
part 'model/plan_list.dart';
part 'model/pledge.dart';
part 'model/pledge_detail.dart';
part 'model/pledge_status.dart';
part 'model/pledge_update_input.dart';
part 'model/public_card.dart';
part 'model/public_card_event.dart';
part 'model/rsvp.dart';
part 'model/rsvp_input.dart';
part 'model/send_manual_message200_response.dart';
part 'model/send_manual_message202_response.dart';
part 'model/send_manual_message_request.dart';
part 'model/send_test_message202_response.dart';
part 'model/send_test_message_request.dart';
part 'model/team.dart';
part 'model/team_members_inner.dart';
part 'model/team_role.dart';
part 'model/update_message_settings_request.dart';
part 'model/update_message_settings_request_settings_inner.dart';
part 'model/update_message_settings_request_settings_inner_schedule.dart';
part 'model/walk_in.dart';
part 'model/walk_in_conflict.dart';
part 'model/walk_in_create_input.dart';
part 'model/walk_in_decision_input.dart';
part 'model/walk_in_status.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
