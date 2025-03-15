import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {

  final Animation<double> animation;
  final int currentTime;

  CountdownTimer({
   required this.animation,
   required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: animation.value,
                strokeWidth: 8,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              );
            },
          ),
        ),
        Text(
          '$currentTime',
          style: TextStyle(fontSize: 48, color: Colors.white),
        ),
      ],
    );
  }
}