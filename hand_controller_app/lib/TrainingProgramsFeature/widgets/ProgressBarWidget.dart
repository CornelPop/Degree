import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBarWidget extends StatefulWidget {
  final double percentage;
  final String text;
  final bool rounded;
  final bool isWhite;

  const ProgressBarWidget({
    Key? key,
    required this.percentage,
    required this.text,
    required this.rounded,
    required this.isWhite,
  }) : super(key: key);

  @override
  _ProgressBarWidgetState createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget> {
  @override
  Widget build(BuildContext context) {
    final decimal = widget.percentage / 100;
    final normalizedPercent = decimal.clamp(0.0, 1.0);
    final displayPercent = widget.percentage.toStringAsFixed(1);

    final textColor = widget.isWhite ? Colors.white : Colors.black;
    final progressColor = widget.isWhite ? Colors.lightBlueAccent : Colors.purple;

    if (!widget.rounded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return LinearPercentIndicator(
                  animation: true,
                  animationDuration: 500,
                  lineHeight: 20.0,
                  percent: normalizedPercent,
                  center: Text(
                    "$displayPercent%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: textColor,
                    ),
                  ),
                  barRadius: const Radius.circular(15),
                  progressColor: progressColor,
                  backgroundColor: Colors.grey.shade200,
                );
              },
            ),
          ),
          Text(
            widget.percentage != -1 ? widget.text : "Finger not used",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          Divider(color: textColor),
        ],
      );
    } else {
      return Column(
        children: [
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 17.0,
            animation: true,
            animationDuration: 500,
            percent: normalizedPercent,
            center: Text(
              "$displayPercent%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: textColor,
              ),
            ),
            footer: Text(
              widget.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: progressColor,
            backgroundColor: Colors.grey.shade200,
          ),
          Divider(color: textColor),
        ],
      );
    }
  }
}
