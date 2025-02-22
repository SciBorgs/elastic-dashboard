import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/services/nt_connection.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class MultiColorView extends NTWidget {
  static const String widgetType = 'Multi Color View';
  @override
  String type = widgetType;

  MultiColorView({
    super.key,
    required super.topic,
    super.dataType,
    super.period,
  }) : super();

  MultiColorView.fromJson({super.key, required super.jsonData})
      : super.fromJson();

  @override
  Widget build(BuildContext context) {
    notifier = context.watch<NTWidgetNotifier?>();

    return StreamBuilder(
      stream: subscription?.periodicStream(yieldAll: false),
      initialData: ntConnection.getLastAnnouncedValue(topic),
      builder: (context, snapshot) {
        notifier = context.watch<NTWidgetNotifier?>();

        List<Object?> hexStringsRaw =
            snapshot.data?.tryCast<List<Object?>>() ?? [];
        List<String> hexStrings = hexStringsRaw.whereType<String>().toList();

        List<Color> colors = [];

        for (String hexString in hexStrings) {
          hexString = hexString.toUpperCase().replaceAll('#', '');

          if (hexString.length == 6) {
            hexString = 'FF$hexString';
          }

          int? hexCode = int.tryParse(hexString, radix: 16);

          if (hexCode != null) {
            colors.add(Color(hexCode));
          }
        }

        if (colors.length < 2) {
          if (colors.length == 1) {
            colors.add(colors[0]);
          } else {
            colors.add(Colors.transparent);
            colors.add(Colors.transparent);
          }
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: colors,
            ),
          ),
        );
      },
    );
  }
}
