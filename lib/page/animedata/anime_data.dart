import 'package:flutter/material.dart';

class AnimeDataPage extends StatefulWidget {
  final int animeId;
  final String? animeName;
  final String? imageUrl;

  const AnimeDataPage({
    super.key,
    required this.animeId,
    this.animeName,
    this.imageUrl,
  });

  @override
  State<AnimeDataPage> createState() => _AnimeDataPageState();
}

class _AnimeDataPageState extends State<AnimeDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animeName ?? '动漫详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示封面图片或占位图标
            if (widget.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageUrl!,
                  width: 200,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                ),
              )
            else
              _buildPlaceholderIcon(),
            
            const SizedBox(height: 20),
            
            // 动漫名称
            if (widget.animeName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.animeName!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            const SizedBox(height: 10),
            
            // 动漫ID
            Text(
              'ID: ${widget.animeId}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '详情页面开发中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.movie,
        size: 80,
        color: Colors.grey,
      ),
    );
  }
}

class AnimeData extends ChangeNotifier {}
