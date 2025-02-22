import 'dart:math';

import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'package:elastic_dashboard/services/nt_connection.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_toggle_switch.dart';
import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class SwerveDriveWidget extends NTWidget {
  static const String widgetType = 'SwerveDrive';
  @override
  String type = widgetType;

  late String frontLeftAngleTopic;
  late String frontLeftVelocityTopic;

  late String frontRightAngleTopic;
  late String frontRightVelocityTopic;

  late String backLeftAngleTopic;
  late String backLeftVelocityTopic;

  late String backRightAngleTopic;
  late String backRightVelocityTopic;

  late String robotAngleTopic;

  bool showRobotRotation = true;

  SwerveDriveWidget({
    super.key,
    required super.topic,
    this.showRobotRotation = true,
    super.dataType,
    super.period,
  }) : super();

  SwerveDriveWidget.fromJson(
      {super.key, required Map<String, dynamic> jsonData})
      : super.fromJson(jsonData: jsonData) {
    showRobotRotation = tryCast(jsonData['show_robot_rotation']) ?? true;
  }

  @override
  void init() {
    super.init();

    frontLeftAngleTopic = '$topic/Front Left Angle';
    frontLeftVelocityTopic = '$topic/Front Left Velocity';

    frontRightAngleTopic = '$topic/Front Right Angle';
    frontRightVelocityTopic = '$topic/Front Right Velocity';

    backLeftAngleTopic = '$topic/Back Left Angle';
    backLeftVelocityTopic = '$topic/Back Left Velocity';

    backRightAngleTopic = '$topic/Back Right Angle';
    backRightVelocityTopic = '$topic/Back Right Velocity';

    robotAngleTopic = '$topic/Robot Angle';
  }

  @override
  void resetSubscription() {
    frontLeftAngleTopic = '$topic/Front Left Angle';
    frontLeftVelocityTopic = '$topic/Front Left Velocity';

    frontRightAngleTopic = '$topic/Front Right Angle';
    frontRightVelocityTopic = '$topic/Front Right Velocity';

    backLeftAngleTopic = '$topic/Back Left Angle';
    backLeftVelocityTopic = '$topic/Back Left Velocity';

    backRightAngleTopic = '$topic/Back Right Angle';
    backRightVelocityTopic = '$topic/Back Right Velocity';

    robotAngleTopic = '$topic/Robot Angle';

    super.resetSubscription();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'show_robot_rotation': showRobotRotation,
    };
  }

  @override
  List<Widget> getEditProperties(BuildContext context) {
    return [
      Center(
        child: DialogToggleSwitch(
          initialValue: showRobotRotation,
          label: 'Show Robot Rotation',
          onToggle: (value) {
            showRobotRotation = value;

            refresh();
          },
        ),
      ),
    ];
  }

  @override
  List<Object> getCurrentData() {
    double frontLeftAngle =
        tryCast(ntConnection.getLastAnnouncedValue(frontLeftAngleTopic)) ?? 0.0;
    double frontLeftVelocity =
        tryCast(ntConnection.getLastAnnouncedValue(frontLeftVelocityTopic)) ??
            0.0;

    double frontRightAngle =
        tryCast(ntConnection.getLastAnnouncedValue(frontRightAngleTopic)) ??
            0.0;
    double frontRightVelocity =
        tryCast(ntConnection.getLastAnnouncedValue(frontRightVelocityTopic)) ??
            0.0;

    double backLeftAngle =
        tryCast(ntConnection.getLastAnnouncedValue(backLeftAngleTopic)) ?? 0.0;
    double backLeftVelocity =
        tryCast(ntConnection.getLastAnnouncedValue(backLeftVelocityTopic)) ??
            0.0;

    double backRightAngle =
        tryCast(ntConnection.getLastAnnouncedValue(backRightAngleTopic)) ?? 0.0;
    double backRightVelocity =
        tryCast(ntConnection.getLastAnnouncedValue(backRightVelocityTopic)) ??
            0.0;

    double robotAngle =
        tryCast(ntConnection.getLastAnnouncedValue(robotAngleTopic)) ?? 0.0;

    return [
      frontLeftAngle,
      frontLeftVelocity,
      frontRightAngle,
      frontRightVelocity,
      backLeftAngle,
      backLeftVelocity,
      backRightAngle,
      backRightVelocity,
      robotAngle,
      showRobotRotation,
    ];
  }

  @override
  Widget build(BuildContext context) {
    notifier = context.watch<NTWidgetNotifier?>();

    return StreamBuilder(
      stream: multiTopicPeriodicStream,
      builder: (context, snapshot) {
        notifier = context.watch<NTWidgetNotifier?>();

        double frontLeftAngle =
            tryCast(ntConnection.getLastAnnouncedValue(frontLeftAngleTopic)) ??
                0.0;
        double frontLeftVelocity = tryCast(
                ntConnection.getLastAnnouncedValue(frontLeftVelocityTopic)) ??
            0.0;

        double frontRightAngle =
            tryCast(ntConnection.getLastAnnouncedValue(frontRightAngleTopic)) ??
                0.0;
        double frontRightVelocity = tryCast(
                ntConnection.getLastAnnouncedValue(frontRightVelocityTopic)) ??
            0.0;

        double backLeftAngle =
            tryCast(ntConnection.getLastAnnouncedValue(backLeftAngleTopic)) ??
                0.0;
        double backLeftVelocity = tryCast(
                ntConnection.getLastAnnouncedValue(backLeftVelocityTopic)) ??
            0.0;

        double backRightAngle =
            tryCast(ntConnection.getLastAnnouncedValue(backRightAngleTopic)) ??
                0.0;
        double backRightVelocity = tryCast(
                ntConnection.getLastAnnouncedValue(backRightVelocityTopic)) ??
            0.0;

        double robotAngle =
            tryCast(ntConnection.getLastAnnouncedValue(robotAngleTopic)) ?? 0.0;

        return LayoutBuilder(builder: (context, constraints) {
          double sideLength =
              min(constraints.maxWidth, constraints.maxHeight) * 0.9;
          return Transform.rotate(
            angle: (showRobotRotation) ? radians(-robotAngle) : 0.0,
            child: SizedBox(
              width: sideLength,
              height: sideLength,
              child: CustomPaint(
                painter: SwerveDrivePainter(
                  frontLeftAngle: frontLeftAngle,
                  frontLeftVelocity: frontLeftVelocity,
                  frontRightAngle: frontRightAngle,
                  frontRightVelocity: frontRightVelocity,
                  backLeftAngle: backLeftAngle,
                  backLeftVelocity: backLeftVelocity,
                  backRightAngle: backRightAngle,
                  backRightVelocity: backRightVelocity,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

class SwerveDrivePainter extends CustomPainter {
  final double frontLeftAngle;
  final double frontLeftVelocity;

  final double frontRightAngle;
  final double frontRightVelocity;

  final double backLeftAngle;
  final double backLeftVelocity;

  final double backRightAngle;
  final double backRightVelocity;

  const SwerveDrivePainter({
    required this.frontLeftAngle,
    required this.frontLeftVelocity,
    required this.frontRightAngle,
    required this.frontRightVelocity,
    required this.backLeftAngle,
    required this.backLeftVelocity,
    required this.backRightAngle,
    required this.backRightVelocity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double robotFrameScale = 0.75;
    const double arrowScale = robotFrameScale * 0.45;

    drawRobotFrame(
        canvas,
        size * robotFrameScale,
        Offset(size.width - size.width * robotFrameScale,
                size.height - size.height * robotFrameScale) /
            2);

    drawRobotDirectionArrow(
        canvas,
        size * arrowScale,
        Offset(size.width - size.width * arrowScale,
                size.height - size.height * arrowScale) /
            2);

    drawMotionArrows(
        canvas,
        size * robotFrameScale,
        Offset(size.width - size.width * robotFrameScale,
                size.height - size.height * robotFrameScale) /
            2);
  }

  void drawRobotFrame(Canvas canvas, Size size, Offset offset) {
    final double scaleFactor = size.width / 128.95 / 0.9;
    final double circleRadius = min(size.width, size.height) / 8;

    Paint framePainter = Paint()
      ..strokeWidth = 1.75 * scaleFactor
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    // Front left circle
    canvas.drawCircle(Offset(circleRadius, circleRadius) + offset, circleRadius,
        framePainter);

    // Front right circle
    canvas.drawCircle(Offset(size.width - circleRadius, circleRadius) + offset,
        circleRadius, framePainter);

    // Back left circle
    canvas.drawCircle(Offset(circleRadius, size.height - circleRadius) + offset,
        circleRadius, framePainter);

    // Back right circle
    canvas.drawCircle(
        Offset(offset.dx + size.width - circleRadius,
            offset.dy + size.height - circleRadius),
        circleRadius,
        framePainter);

    // Top line
    canvas.drawLine(
        Offset(circleRadius * 2, circleRadius) + offset,
        Offset(size.width - circleRadius * 2, circleRadius) + offset,
        framePainter);

    // Right line
    canvas.drawLine(
        Offset(size.width - circleRadius, circleRadius * 2) + offset,
        Offset(size.width - circleRadius, size.height - circleRadius * 2) +
            offset,
        framePainter);

    // Bottom line
    canvas.drawLine(
        Offset(circleRadius * 2, size.height - circleRadius) + offset,
        Offset(size.width - circleRadius * 2, size.height - circleRadius) +
            offset,
        framePainter);

    // Left line
    canvas.drawLine(
        Offset(circleRadius, circleRadius * 2) + offset,
        Offset(circleRadius, size.height - circleRadius * 2) + offset,
        framePainter);
  }

  void drawMotionArrows(Canvas canvas, Size size, Offset offset) {
    final double circleRadius = min(size.width, size.height) / 8;
    const double arrowAngle = 40 * pi / 180;

    final double scaleFactor = size.width / 128.95 / 0.9;

    final double pixelsPerMPS = 7.0 / 1.0 * scaleFactor;

    final double minArrowBase = 6.5 * scaleFactor;
    final double maxArrowBase = 16.0 * scaleFactor;

    Paint arrowPaint = Paint()
      ..strokeWidth = 2 * scaleFactor
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    Paint anglePaint = Paint()
      ..strokeWidth = 3.5 * scaleFactor
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Front left angle indicator thing
    Rect frontLeftWheel = Rect.fromCenter(
        center: Offset(circleRadius, circleRadius) + offset,
        width: circleRadius * 2,
        height: circleRadius * 2);

    canvas.drawArc(frontLeftWheel, radians(-(frontLeftAngle + 22.5) - 90),
        radians(45), false, anglePaint);

    // Front left vector arrow
    if (frontLeftVelocity.abs() >= 0.05) {
      double frontLeftAngle = this.frontLeftAngle;

      frontLeftAngle += 90;
      frontLeftAngle *= -1;

      if (frontLeftVelocity < 0) {
        frontLeftAngle -= 180;
      }

      frontLeftAngle = radians(frontLeftAngle);

      double frontLeftArrowLength = frontLeftVelocity.abs() * pixelsPerMPS;
      double frontLeftArrowBase =
          (frontLeftArrowLength / 3.0).clamp(minArrowBase, maxArrowBase);

      canvas.drawLine(
          Offset(circleRadius, circleRadius) + offset,
          Offset(frontLeftArrowLength * cos(frontLeftAngle),
                  frontLeftArrowLength * sin(frontLeftAngle)) +
              Offset(circleRadius, circleRadius) +
              offset,
          arrowPaint);

      drawArrowHead(
          canvas,
          Offset(circleRadius, circleRadius) / 2 + offset,
          frontLeftArrowLength * cos(frontLeftAngle) + circleRadius / 2,
          frontLeftArrowLength * sin(frontLeftAngle) + circleRadius / 2,
          frontLeftAngle,
          arrowAngle,
          frontLeftArrowBase,
          arrowPaint);
    } else {
      // Draw an X
      drawX(canvas, Offset(circleRadius, circleRadius) + offset, circleRadius,
          arrowPaint);
    }

    // Front right angle indicator thing
    Rect frontRightWheel = Rect.fromCenter(
        center: Offset(size.width - circleRadius, circleRadius) + offset,
        width: circleRadius * 2,
        height: circleRadius * 2);

    canvas.drawArc(frontRightWheel, radians(-(frontRightAngle + 22.5) - 90),
        radians(45), false, anglePaint);

    // Front right vector arrow
    if (frontRightVelocity.abs() >= 0.05) {
      double frontRightAngle = this.frontRightAngle;

      frontRightAngle += 90;
      frontRightAngle *= -1;

      if (frontRightVelocity < 0) {
        frontRightAngle -= 180;
      }

      frontRightAngle = radians(frontRightAngle);

      double frontRightArrowLength = frontRightVelocity.abs() * pixelsPerMPS;
      double frontRightArrowBase =
          (frontRightArrowLength / 3.0).clamp(minArrowBase, maxArrowBase);

      canvas.drawLine(
          Offset(size.width - circleRadius, circleRadius) + offset,
          Offset(frontRightArrowLength * cos(frontRightAngle),
                  frontRightArrowLength * sin(frontRightAngle)) +
              Offset(size.width - circleRadius, circleRadius) +
              offset,
          arrowPaint);

      drawArrowHead(
          canvas,
          Offset(size.width - circleRadius / 2, circleRadius / 2) + offset,
          frontRightArrowLength * cos(frontRightAngle) - circleRadius / 2,
          frontRightArrowLength * sin(frontRightAngle) + circleRadius / 2,
          frontRightAngle,
          arrowAngle,
          frontRightArrowBase,
          arrowPaint);
    } else {
      // Draw an X
      drawX(canvas, Offset(size.width - circleRadius, circleRadius) + offset,
          circleRadius, arrowPaint);
    }

    // Back left angle indicator thing
    Rect backLeftWheel = Rect.fromCenter(
        center: Offset(circleRadius, size.height - circleRadius) + offset,
        width: circleRadius * 2,
        height: circleRadius * 2);

    canvas.drawArc(backLeftWheel, radians(-(backLeftAngle + 22.5) - 90),
        radians(45), false, anglePaint);

    // Back left vector arrow
    if (backLeftVelocity.abs() >= 0.05) {
      double backLeftAngle = this.backLeftAngle;

      backLeftAngle += 90;
      backLeftAngle *= -1;

      if (backLeftVelocity < 0) {
        backLeftAngle -= 180;
      }

      backLeftAngle = radians(backLeftAngle);

      double backLeftArrowLength = backLeftVelocity.abs() * pixelsPerMPS;
      double backLeftArrowBase =
          (backLeftArrowLength / 3.0).clamp(minArrowBase, maxArrowBase);

      canvas.drawLine(
          Offset(circleRadius, size.height - circleRadius) + offset,
          Offset(backLeftArrowLength * cos(backLeftAngle),
                  backLeftArrowLength * sin(backLeftAngle)) +
              Offset(circleRadius, size.height - circleRadius) +
              offset,
          arrowPaint);

      drawArrowHead(
          canvas,
          Offset(circleRadius / 2, size.height - circleRadius / 2) + offset,
          backLeftArrowLength * cos(backLeftAngle) + circleRadius / 2,
          backLeftArrowLength * sin(backLeftAngle) - circleRadius / 2,
          backLeftAngle,
          arrowAngle,
          backLeftArrowBase,
          arrowPaint);
    } else {
      // Draw an X
      drawX(canvas, Offset(circleRadius, size.height - circleRadius) + offset,
          circleRadius, arrowPaint);
    }

    // Back right angle indicator thing
    Rect backRightWheel = Rect.fromCenter(
        center: Offset(size.width - circleRadius, size.height - circleRadius) +
            offset,
        width: circleRadius * 2,
        height: circleRadius * 2);

    canvas.drawArc(backRightWheel, radians(-(backRightAngle + 22.5) - 90),
        radians(45), false, anglePaint);

    // Back right vector arrow
    if (backRightVelocity.abs() >= 0.05) {
      double backRightAngle = this.backRightAngle;

      backRightAngle += 90;
      backRightAngle *= -1;

      if (backRightVelocity < 0) {
        backRightAngle -= 180;
      }

      backRightAngle = radians(backRightAngle);

      double backRightArrowLength = backRightVelocity.abs() * pixelsPerMPS;
      double backRightArrowBase =
          (backRightArrowLength / 3.0).clamp(minArrowBase, maxArrowBase);

      canvas.drawLine(
          Offset(size.width - circleRadius, size.height - circleRadius) +
              offset,
          Offset(backRightArrowLength * cos(backRightAngle),
                  backRightArrowLength * sin(backRightAngle)) +
              Offset(size.width - circleRadius, size.height - circleRadius) +
              offset,
          arrowPaint);

      drawArrowHead(
          canvas,
          Offset(size.width - circleRadius / 2,
                  size.height - circleRadius / 2) +
              offset,
          backRightArrowLength * cos(backRightAngle) - circleRadius / 2,
          backRightArrowLength * sin(backRightAngle) - circleRadius / 2,
          backRightAngle,
          arrowAngle,
          backRightArrowBase,
          arrowPaint);
    } else {
      // Draw an X
      drawX(
          canvas,
          Offset(size.width - circleRadius, size.height - circleRadius) +
              offset,
          circleRadius,
          arrowPaint);
    }
  }

  void drawX(Canvas canvas, Offset offset, double circleRadius, Paint xPaint) {
    canvas.drawLine(Offset(circleRadius / 2, circleRadius / 2) * 0.75 + offset,
        -Offset(circleRadius / 2, circleRadius / 2) * 0.75 + offset, xPaint);

    canvas.drawLine(
        -Offset(-circleRadius / 2, circleRadius / 2) * 0.75 + offset,
        Offset(-circleRadius / 2, circleRadius / 2) * 0.75 + offset,
        xPaint);
  }

  void drawArrowHead(Canvas canvas, Offset center, double tipX, double tipY,
      double arrowRotation, double arrowAngle, double base, Paint arrowPaint) {
    Path arrowPath = Path()
      ..moveTo(center.dx + tipX - base * cos(arrowRotation - arrowAngle),
          center.dy + tipY - base * sin(arrowRotation - arrowAngle))
      ..lineTo(center.dx + tipX, center.dy + tipY)
      ..lineTo(center.dx + tipX - base * cos(arrowRotation + arrowAngle),
          center.dy + tipY - base * sin(arrowRotation + arrowAngle));

    canvas.drawPath(arrowPath, arrowPaint);
  }

  void drawRobotDirectionArrow(Canvas canvas, Size size, Offset offset) {
    final double scaleFactor = size.width / 58.0 / 0.9;

    const double arrowAngle = 40 * pi / 180;
    final double base = size.width * 0.45;
    const double arrowRotation = -pi / 2;
    const double tipX = 0;
    final double tipY = -size.height / 2;

    Offset center = Offset(size.width, size.height) / 2 + offset;

    Paint arrowPainter = Paint()
      ..strokeWidth = 3.5 * scaleFactor
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    Path arrowHead = Path()
      ..moveTo(center.dx + tipX - base * cos(arrowRotation - arrowAngle),
          center.dy + tipY - base * sin(arrowRotation - arrowAngle))
      ..lineTo(center.dx + tipX, center.dy + tipY)
      ..lineTo(center.dx + tipX - base * cos(arrowRotation + arrowAngle),
          center.dy + tipY - base * sin(arrowRotation + arrowAngle));

    canvas.drawPath(arrowHead, arrowPainter);
    canvas.drawLine(Offset(tipX, tipY) + center, Offset(tipX, -tipY) + center,
        arrowPainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
