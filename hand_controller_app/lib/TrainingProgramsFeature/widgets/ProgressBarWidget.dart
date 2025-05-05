import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBarWidget extends StatefulWidget {
  final double percentage;
  final String text;
  final bool rounded;

  const ProgressBarWidget({
    Key? key,
    required this.percentage,
    required this.text,
    required this.rounded,
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
                  center: Text("$displayPercent%"),
                  barRadius: const Radius.circular(15),
                  progressColor: Colors.purple,
                  backgroundColor: Colors.grey[300],
                );
              },
            ),
          ),
          Text(
            widget.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
          Divider()
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            footer: Text(
              widget.text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.purple,
            backgroundColor: Colors.grey,
          ),
          Divider(),
        ],
      );
    }
  }
}