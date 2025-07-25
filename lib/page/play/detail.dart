import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final int? animeId;
  final String? animeName;

  const DetailPage({
    super.key,
    this.animeId,
    this.animeName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (animeName != null) ...[
            Text(
              animeName!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
