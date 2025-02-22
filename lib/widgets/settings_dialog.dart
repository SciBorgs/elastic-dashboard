import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elastic_dashboard/services/ip_address_util.dart';
import 'package:elastic_dashboard/services/nt_connection.dart';
import 'package:elastic_dashboard/services/settings.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_color_picker.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_dropdown_chooser.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_text_input.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_toggle_switch.dart';

class SettingsDialog extends StatefulWidget {
  final SharedPreferences preferences;

  final Function(String? data)? onIPAddressChanged;
  final Function(String? data)? onTeamNumberChanged;
  final Function(IPAddressMode mode)? onIPAddressModeChanged;
  final Function(Color color)? onColorChanged;
  final Function(bool value)? onGridToggle;
  final Function(String? gridSize)? onGridSizeChanged;
  final Function(String? radius)? onCornerRadiusChanged;
  final Function(bool value)? onResizeToDSChanged;
  final Function(String? value)? onDefaultPeriodChanged;
  final Function(String? value)? onDefaultGraphPeriodChanged;

  const SettingsDialog({
    super.key,
    required this.preferences,
    this.onTeamNumberChanged,
    this.onIPAddressModeChanged,
    this.onIPAddressChanged,
    this.onColorChanged,
    this.onGridToggle,
    this.onGridSizeChanged,
    this.onCornerRadiusChanged,
    this.onResizeToDSChanged,
    this.onDefaultPeriodChanged,
    this.onDefaultGraphPeriodChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Container(
        constraints: const BoxConstraints(
          maxHeight: 250,
          maxWidth: 650,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ..._generalSettings(),
                  const Divider(),
                  ..._ipAddressSettings(),
                ],
              ),
            ),
            const VerticalDivider(),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ..._gridSettings(),
                  const Divider(),
                  ..._networkTablesSettings(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  List<Widget> _generalSettings() {
    Color currentColor = Color(
        widget.preferences.getInt('team_color') ?? Colors.blueAccent.value);
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: DialogTextInput(
              initialText:
                  widget.preferences.getInt(PrefKeys.teamNumber).toString(),
              label: 'Team Number',
              onSubmit: (data) {
                setState(() {
                  widget.onTeamNumberChanged?.call(data);
                });
              },
              formatter: FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
            ),
          ),
          Flexible(
            child: DialogColorPicker(
              onColorPicked: (color) => widget.onColorChanged?.call(color),
              label: 'Team Color',
              initialColor: currentColor,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _ipAddressSettings() {
    return [
      const Align(
        alignment: Alignment.topLeft,
        child: Text('IP Address Settings'),
      ),
      const SizedBox(height: 5),
      const Text('IP Address Mode'),
      DialogDropdownChooser<IPAddressMode>(
        onSelectionChanged: (mode) {
          if (mode == null) {
            return;
          }

          widget.onIPAddressModeChanged?.call(mode);

          setState(() {});
        },
        choices: IPAddressMode.values,
        initialValue: Settings.ipAddressMode,
      ),
      const SizedBox(height: 5),
      StreamBuilder(
          stream: ntConnection.dsConnectionStatus(),
          initialData: ntConnection.isDSConnected,
          builder: (context, snapshot) {
            bool dsConnected = tryCast(snapshot.data) ?? false;

            return DialogTextInput(
              enabled: Settings.ipAddressMode == IPAddressMode.custom ||
                  (Settings.ipAddressMode == IPAddressMode.driverStation &&
                      !dsConnected),
              initialText: widget.preferences.getString(PrefKeys.ipAddress),
              label: 'IP Address',
              onSubmit: (String? data) {
                setState(() {
                  widget.onIPAddressChanged?.call(data);
                });
              },
            );
          })
    ];
  }

  List<Widget> _gridSettings() {
    return [
      const Align(
        alignment: Alignment.topLeft,
        child: Text('Grid Settings'),
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: DialogToggleSwitch(
              initialValue: widget.preferences.getBool(PrefKeys.showGrid) ??
                  Settings.showGrid,
              label: 'Show Grid',
              onToggle: (value) {
                setState(() {
                  widget.onGridToggle?.call(value);
                });
              },
            ),
          ),
          Flexible(
            child: DialogTextInput(
              initialText:
                  widget.preferences.getInt(PrefKeys.gridSize)?.toString() ??
                      Settings.gridSize.toString(),
              label: 'Grid Size',
              onSubmit: (value) {
                setState(() {
                  widget.onGridSizeChanged?.call(value);
                });
              },
              formatter: FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
            ),
          )
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 2,
            child: DialogTextInput(
              initialText: widget.preferences
                      .getDouble(PrefKeys.cornerRadius)
                      ?.toString() ??
                  Settings.cornerRadius.toString(),
              label: 'Corner Radius',
              onSubmit: (value) {
                setState(() {
                  widget.onCornerRadiusChanged?.call(value);
                });
              },
              formatter: FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            ),
          ),
          Flexible(
            flex: 3,
            child: DialogToggleSwitch(
              initialValue:
                  widget.preferences.getBool(PrefKeys.autoResizeToDS) ??
                      Settings.autoResizeToDS,
              label: 'Resize to Driver Station Height',
              onToggle: (value) {
                setState(() {
                  widget.onResizeToDSChanged?.call(value);
                });
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _networkTablesSettings() {
    return [
      const Align(
        alignment: Alignment.topLeft,
        child: Text('Network Tables Settings'),
      ),
      const SizedBox(height: 5),
      Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: DialogTextInput(
                  initialText:
                      (widget.preferences.getDouble(PrefKeys.defaultPeriod) ??
                              Settings.defaultPeriod)
                          .toString(),
                  label: 'Default Period',
                  onSubmit: (value) {
                    setState(() {
                      widget.onDefaultPeriodChanged?.call(value);
                    });
                  },
                  formatter:
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))),
            ),
            Flexible(
              child: DialogTextInput(
                  initialText: (widget.preferences
                              .getDouble(PrefKeys.defaultGraphPeriod) ??
                          Settings.defaultGraphPeriod)
                      .toString(),
                  label: 'Default Graph Period',
                  onSubmit: (value) {
                    setState(() {
                      widget.onDefaultGraphPeriodChanged?.call(value);
                    });
                  },
                  formatter:
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))),
            ),
          ],
        ),
      ),
    ];
  }
}
