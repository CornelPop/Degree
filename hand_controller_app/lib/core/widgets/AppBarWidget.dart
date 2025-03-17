import 'package:flutter/material.dart';
import '../../GlobalThemeData.dart';

class AppBarWidget extends StatelessWidget {
  final IconData? leadingIcon; // Accepts custom leading icon

  const AppBarWidget({super.key, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text('HandHero', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Icon(
            Icons.question_mark,
            color: Colors.white,
          ),
          onPressed: () {},
        )
      ],
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              leadingIcon ?? Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              if (leadingIcon == Icons.arrow_back) {
                Navigator.pop(context);
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          );
        },
      ),
      elevation: 0,
    );
  }
}
