import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';
import '../../modules/bangumi_data.dart';
import 'dart:ui';

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
      final data = await BangumiService.getInfoByID(widget.animeId);
      
      if (data != null) {
        // 使用数据解析器解析数据
        final parsedData = BangumiDataParser.parseDetailData(data);
        
        if (parsedData != null) {
          setState(() {
            _animeDetailData = parsedData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '数据解析失败';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = '获取数据失败';
          _isLoading = false;
        });
      }
    } catch (e) {
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

    return CustomScrollView(
      slivers: [
        // 顶部背景模糊区域
        SliverToBoxAdapter(
          child: _buildHeaderSection(),
        ),
        // 操作按钮区域
        SliverToBoxAdapter(
          child: _buildActionButtons(),
        ),
        // 详情标签页区域
        SliverToBoxAdapter(
          child: _buildDetailTabs(),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    if (_animeDetailData == null) return const SizedBox.shrink();

    final data = _animeDetailData!;
    final imageUrl = data.images.bestUrl.isNotEmpty 
        ? data.images.bestUrl 
        : (widget.imageUrl ?? '');

    return Container(
      height: 300,
      child: Stack(
        children: [
          // 背景模糊图片
          Positioned.fill(
            child: _buildBlurredBackground(imageUrl),
          ),
          // 渐变遮罩
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black26,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ),
          // 前景内容
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧封面图片
                    _buildCoverImage(),
                    const SizedBox(width: 16),
                    // 右侧信息
                    Expanded(
                      child: _buildAnimeInfo(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.movie,
            size: 80,
            color: Colors.white24,
          ),
        ),
      );
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(
              Icons.movie,
              size: 80,
              color: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final imageUrl = _animeDetailData?.images.bestUrl ?? widget.imageUrl ?? '';
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildAnimeInfo() {
    if (_animeDetailData == null) return const SizedBox.shrink();
    
    final data = _animeDetailData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          data.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // 放送日期和话数
        Text(
          '${data.date} · 全 ${data.totalEpisodes} 话',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 评分区域
        if (data.rating != null) ...[
          Row(
            children: [
              // 评分星星
              ...List.generate(5, (index) {
                final score = data.rating!.score;
                final fullStars = (score / 2).floor();
                final hasHalfStar = (score / 2) - fullStars >= 0.5;
                
                if (index < fullStars) {
                  return const Icon(Icons.star, color: Colors.amber, size: 16);
                } else if (index == fullStars && hasHalfStar) {
                  return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                } else {
                  return const Icon(Icons.star_border, color: Colors.white54, size: 16);
                }
              }),
              const SizedBox(width: 8),
              Text(
                data.scoreText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${data.totalRatingCount} 人评分 / #${data.rating!.rank}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // 收藏数据
        if (data.collection != null) ...[
          Text(
            '${data.totalCollectionCount} 收藏 / ${data.collection!.doing} 在看 / ${data.collection!.wish} 想看',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // 标签
        if (data.mainTags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: data.mainTags.take(3).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_animeDetailData == null) return const SizedBox.shrink();

    final data = _animeDetailData!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.play_arrow, '播放', () {
            // TODO: Implement play functionality
          }),
          _buildActionButton(Icons.bookmark_border, '收藏', () {
            // TODO: Implement collection functionality
          }),
          _buildActionButton(Icons.share, '分享', () {
            // TODO: Implement share functionality
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTabs() {
    if (_animeDetailData == null) return const SizedBox.shrink();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // 标签栏
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: '详情'),
                Tab(text: '简介'),
              ],
            ),
          ),
          // 内容区域
          Container(
            height: 400,
            child: TabBarView(
              children: [
                _buildDetailInfo(),
                _buildSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (_animeDetailData == null || _animeDetailData!.summary.isEmpty) {
      return const Center(
        child: Text(
          '暂无简介',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 处理换行符和格式化文本
    final formattedSummary = _animeDetailData!.summary
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        formattedSummary,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailInfo() {
    if (_animeDetailData == null) {
      return const Center(
        child: Text(
          '暂无详细信息',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final data = _animeDetailData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('基本信息', [
            _buildInfoRow('原名', data.name),
            _buildInfoRow('中文名', data.nameCn),
            _buildInfoRow('类型', data.typeText),
            _buildInfoRow('总集数', '${data.totalEpisodes}话'),
            _buildInfoRow('放送日期', data.date),
            _buildInfoRow('播放平台', data.platform),
          ]),
          
          const SizedBox(height: 20),
          
          _buildInfoSection('评分信息', [
            _buildInfoRow('评分', data.scoreText),
            _buildInfoRow('评价人数', '${data.totalRatingCount}人'),
            if (data.rating != null) _buildInfoRow('排名', '第${data.rating!.rank}名'),
          ]),
          
          const SizedBox(height: 20),
          
          if (data.collection != null) ...[
            _buildInfoSection('收藏信息', [
              _buildInfoRow('总收藏', '${data.totalCollectionCount}人'),
              _buildInfoRow('想看', '${data.collection!.wish}人'),
              _buildInfoRow('在看', '${data.collection!.doing}人'),
              _buildInfoRow('看过', '${data.collection!.collect}人'),
              _buildInfoRow('搁置', '${data.collection!.onHold}人'),
              _buildInfoRow('抛弃', '${data.collection!.dropped}人'),
            ]),
            
            const SizedBox(height: 20),
          ],
          
          if (data.mainTags.isNotEmpty) ...[
            _buildInfoSection('标签', [
              _buildTagsRow(data.mainTags),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[400],
      child: const Icon(
        Icons.movie,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

