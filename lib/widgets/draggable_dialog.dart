import 'package:flutter/material.dart';

import 'package:flutter_box_transform/flutter_box_transform.dart';

import 'package:elastic_dashboard/services/settings.dart';

class DraggableDialog extends StatefulWidget {
  final Widget dialog;
  final Rect initialPosition;

  const DraggableDialog({
    super.key,
    required this.dialog,
    this.initialPosition = const Rect.fromLTWH(50.0, 50.0, 400, 500),
  });

  @override
  State<DraggableDialog> createState() => _DraggableDialogState();
}

class _DraggableDialogState extends State<DraggableDialog> {
  late Rect position;

  @override
  void initState() {
    super.initState();

    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
      constraints: BoxConstraints(
          minWidth: Settings.gridSize.toDouble(),
          minHeight: Settings.gridSize.toDouble(),
          maxWidth: double.infinity,
          maxHeight: double.infinity),
      clampingRect: const Rect.fromLTWH(0, 0, double.infinity, double.infinity),
      allowFlippingWhileResizing: false,
      visibleHandles: const {},
      resizeModeResolver: () => ResizeMode.freeform,
      rect: position,
      onChanged: (result, event) {
        setState(() => position = result.rect);
      },
      contentBuilder: (context, rect, flip) {
        return widget.dialog;
      },
    );
  }
}
