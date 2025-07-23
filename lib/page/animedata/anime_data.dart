import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';
import '../../modules/bangumi_data.dart';

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
  BangumiDetailData? _animeDetailData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnimeDetail();
  }

  Future<void> _loadAnimeDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('正在获取动漫详情，ID: ${widget.animeId}');
      final data = await BangumiService.getInfoByID(widget.animeId);

      if (data != null) {
        print('获取动漫详情成功:');
        print('原始数据: $data');

        // 使用数据解析器解析数据
        final parsedData = BangumiDataParser.parseDetailData(data);

        if (parsedData != null) {
          print('数据解析成功:');
          print('动漫名称: ${parsedData.displayName}');
          print('评分: ${parsedData.scoreText}');
          print('类型: ${parsedData.typeText}');
          print('标签: ${parsedData.mainTags}');

          setState(() {
            _animeDetailData = parsedData;
            _isLoading = false;
          });
        } else {
          print('数据解析失败');
          setState(() {
            _errorMessage = '数据解析失败';
            _isLoading = false;
          });
        }
      } else {
        print('获取动漫详情失败: 返回数据为空');
        setState(() {
          _errorMessage = '获取数据失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('获取动漫详情异常: $e');
      setState(() {
        _errorMessage = '网络错误: $e';
        _isLoading = false;
      });
    }
  }

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              '正在加载动漫详情...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAnimeDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildSummary(),
          const SizedBox(height: 24),
          _buildDetailInfo(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Center(
      child: Column(
        children: [
          // 显示封面图片（优先使用API返回的图片）
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildCoverImage(),
          ),

          const SizedBox(height: 20),

          // 动漫名称（使用解析后的数据）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _animeDetailData?.displayName ?? widget.animeName ?? '未知动漫',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // 原名（如果与显示名称不同）
          if (_animeDetailData != null &&
              _animeDetailData!.name != _animeDetailData!.displayName &&
              _animeDetailData!.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _animeDetailData!.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 10),

          // 基本信息行
          if (_animeDetailData != null) ...[
            _buildInfoChip('${_animeDetailData!.typeText}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip('${_animeDetailData!.scoreText}分'),
                const SizedBox(width: 8),
                _buildInfoChip('${_animeDetailData!.totalEpisodes}话'),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // 动漫ID
          Text(
            'ID: ${widget.animeId}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    // 优先使用API返回的图片
    String? imageUrl = _animeDetailData?.images.bestUrl;

    // 如果API没有图片或图片为空，使用传入的图片
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = widget.imageUrl;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 200,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
      );
    }

    return _buildPlaceholderIcon();
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummary() {
    if (_animeDetailData == null || _animeDetailData!.summary.isEmpty) {
      return const SizedBox.shrink();
    }

    // 处理换行符和格式化文本
    final formattedSummary = _animeDetailData!.summary
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '简介:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Text(
            formattedSummary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo() {
    if (_animeDetailData == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '详细信息:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatDetailData(),
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  String _formatDetailData() {
    if (_animeDetailData == null) return '暂无数据';

    final data = _animeDetailData!;
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('基本信息:');
    buffer.writeln('名称: ${data.displayName}');
    buffer.writeln('原名: ${data.name}');
    buffer.writeln('类型: ${data.typeText}');
    buffer.writeln('总集数: ${data.totalEpisodes}话');
    buffer.writeln('放送日期: ${data.date}');
    buffer.writeln('播放平台: ${data.platform}');

    buffer.writeln('\n评分信息:');
    buffer.writeln('评分: ${data.scoreText}');
    buffer.writeln('评价人数: ${data.totalRatingCount}人');
    if (data.rating != null) {
      buffer.writeln('排名: 第${data.rating!.rank}名');
    }

    buffer.writeln('\n收藏信息:');
    buffer.writeln('总收藏: ${data.totalCollectionCount}人');
    if (data.collection != null) {
      buffer.writeln('- 想看: ${data.collection!.wish}人');
      buffer.writeln('- 在看: ${data.collection!.doing}人');
      buffer.writeln('- 看过: ${data.collection!.collect}人');
      buffer.writeln('- 搁置: ${data.collection!.onHold}人');
      buffer.writeln('- 抛弃: ${data.collection!.dropped}人');
    }

    if (data.mainTags.isNotEmpty) {
      buffer.writeln('\n主要标签:');
      buffer.writeln(data.mainTags.join(' · '));
    }

    buffer.writeln('\n完整数据已在控制台打印');

    return buffer.toString();
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

