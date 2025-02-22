import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:elastic_dashboard/services/nt_connection.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_text_input.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class NumberSlider extends NTWidget {
  static const String widgetType = 'Number Slider';
  @override
  final String type = widgetType;

  late double minValue;
  late double maxValue;
  late int divisions;

  double _currentValue = 0.0;
  double _previousValue = 0.0;

  NumberSlider({
    super.key,
    required super.topic,
    this.minValue = -1.0,
    this.maxValue = 1.0,
    this.divisions = 5,
    super.dataType,
    super.period,
  }) : super();

  NumberSlider.fromJson({super.key, required Map<String, dynamic> jsonData})
      : super.fromJson(jsonData: jsonData) {
    minValue =
        tryCast(jsonData['min_value']) ?? tryCast(jsonData['min']) ?? -1.0;
    maxValue =
        tryCast(jsonData['max_value']) ?? tryCast(jsonData['max']) ?? 1.0;
    divisions = tryCast(jsonData['divisions']) ??
        tryCast(jsonData['numOfTickMarks']) ??
        5;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'min_value': minValue,
      'max_value': maxValue,
      'divisions': divisions,
    };
  }

  @override
  List<Widget> getEditProperties(BuildContext context) {
    return [
      // Min and max values
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: DialogTextInput(
              onSubmit: (value) {
                double? newMin = double.tryParse(value);
                if (newMin == null) {
                  return;
                }
                minValue = newMin;
                refresh();
              },
              formatter: FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
              label: 'Min Value',
              initialText: minValue.toString(),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: DialogTextInput(
              onSubmit: (value) {
                double? newMax = double.tryParse(value);
                if (newMax == null) {
                  return;
                }
                maxValue = newMax;
                refresh();
              },
              formatter: FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
              label: 'Max Value',
              initialText: maxValue.toString(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      // Number of divisions
      DialogTextInput(
        onSubmit: (value) {
          int? newDivisions = int.tryParse(value);
          if (newDivisions == null || newDivisions < 2) {
            return;
          }
          divisions = newDivisions;
          refresh();
        },
        formatter: FilteringTextInputFormatter.digitsOnly,
        label: 'Divisions',
        initialText: divisions.toString(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    notifier = context.watch<NTWidgetNotifier?>();

    return StreamBuilder(
      stream: subscription?.periodicStream(),
      initialData: ntConnection.getLastAnnouncedValue(topic),
      builder: (context, snapshot) {
        double value = tryCast(snapshot.data) ?? 0.0;

        double clampedValue = value.clamp(minValue, maxValue);

        if (clampedValue != _previousValue) {
          _currentValue = clampedValue;
        }

        _previousValue = clampedValue;

        double divisionSeparation = (maxValue - minValue) / (divisions - 1);

        return Column(
          children: [
            Text(
              _currentValue.toStringAsFixed(2),
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: SfLinearGauge(
                key: UniqueKey(),
                minimum: minValue,
                maximum: maxValue,
                labelPosition: LinearLabelPosition.inside,
                tickPosition: LinearElementPosition.cross,
                interval: divisionSeparation,
                axisTrackStyle: const LinearAxisTrackStyle(
                  edgeStyle: LinearEdgeStyle.bothCurve,
                ),
                markerPointers: [
                  LinearShapePointer(
                    value: _currentValue,
                    color: Theme.of(context).colorScheme.primary,
                    height: 15.0,
                    width: 15.0,
                    animationDuration: 0,
                    shapeType: LinearShapePointerType.circle,
                    position: LinearElementPosition.cross,
                    dragBehavior: LinearMarkerDragBehavior.free,
                    onChanged: (value) {
                      _currentValue = value;
                    },
                    onChangeEnd: (value) {
                      bool publishTopic = ntTopic == null ||
                          !ntConnection.isTopicPublished(ntTopic);

                      createTopicIfNull();

                      if (ntTopic == null) {
                        return;
                      }

                      if (publishTopic) {
                        ntConnection.nt4Client.publishTopic(ntTopic!);
                      }

                      ntConnection.updateDataFromTopic(ntTopic!, value);

                      _previousValue = value;
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
