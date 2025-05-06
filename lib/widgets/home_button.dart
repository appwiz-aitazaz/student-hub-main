import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/dashboard');
      },
      backgroundColor: Colors.teal,
      child: const Icon(Icons.home, color: Colors.white),
    );
  }
}