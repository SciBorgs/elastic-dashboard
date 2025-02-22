import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../draggable_containers/models/layout_container_model.dart';

class LayoutDragTile extends StatelessWidget {
  final String title;

  LayoutContainerModel Function()? layoutBuilder;

  LayoutContainerModel? draggingWidget;

  final Function(Offset globalPosition, LayoutContainerModel widget)?
      onDragUpdate;
  final Function(LayoutContainerModel widget)? onDragEnd;

  LayoutDragTile({
    super.key,
    required this.title,
    this.layoutBuilder,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: GestureDetector(
        onPanStart: (details) {
          if (draggingWidget != null) {
            return;
          }

          // Prevents 2 finger drags from dragging a widget
          if (details.kind != null &&
              details.kind! == PointerDeviceKind.trackpad) {
            draggingWidget = null;
            return;
          }

          draggingWidget = layoutBuilder?.call();
        },
        onPanUpdate: (details) {
          if (draggingWidget == null) {
            return;
          }

          onDragUpdate?.call(
              details.globalPosition -
                  Offset(draggingWidget!.displayRect.width,
                          draggingWidget!.displayRect.height) /
                      2,
              draggingWidget!);
        },
        onPanEnd: (details) {
          if (draggingWidget == null) {
            return;
          }

          onDragEnd?.call(draggingWidget!);

          draggingWidget = null;
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16.0),
          child: ListTile(
            style: ListTileStyle.drawer,
            dense: true,
            contentPadding: const EdgeInsets.only(right: 20.0),
            leading: const SizedBox(width: 16.0),
            title: Text(title),
          ),
        ),
      ),
    );
  }
}
