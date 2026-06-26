import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  final String appName;
  final VoidCallback onTap;

  const AppTile({
    super.key,
    required this.appName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Text(
          appName,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}