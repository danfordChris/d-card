import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// An error/notice tile in the danger tone, with an optional action (e.g. retry).
class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => DcNoticeTile(
    tone: DcTone.danger,
    icon: HugeIcons.strokeRoundedAlert02,
    message: text,
    trailing: action,
  );
}
