import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/modules/bangumi_data.dart';
import 'package:flutter_app/page/video/video_info.dart';

/// 自定义AppBar组件
class AnimeDetailAppBar extends StatelessWidget {
  final String title;
  final bool innerBoxIsScrolled;
  final TabController tabController;
  final List<String> tabs;
  final Widget background;

  const AnimeDetailAppBar({
    super.key,
    required this.title,
    required this.innerBoxIsScrolled,
    required this.tabController,
    required this.tabs,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      title: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text(title),
      ),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      // 添加滚动时的不透明背景
      backgroundColor: innerBoxIsScrolled
          ? Colors.white
          : Colors.transparent,
      foregroundColor: Colors.black,
      leading: IconButton(
        onPressed: () {
          Navigator.maybePop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        if (innerBoxIsScrolled)
          IconButton(
            onPressed: () {
              // TODO: 实现收藏功能
            },
            icon: const Icon(Icons.favorite_border),
          ),
        IconButton(
          onPressed: () {
            // TODO: 实现分享功能
          },
          icon: const Icon(Icons.share),
        ),
        const SizedBox(width: 8),
      ],
      stretch: true,
      centerTitle: false,
      // 高度设置
      expandedHeight: 300 + kTextTabBarHeight + kToolbarHeight, // 280 → 320 增加40px适应新间距
      collapsedHeight: kTextTabBarHeight +
          kToolbarHeight +
          MediaQuery.paddingOf(context).top,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: background,
      ),
      forceElevated: innerBoxIsScrolled,
      bottom: AnimeDetailTabBar(
        tabController: tabController,
        tabs: tabs,
        innerBoxIsScrolled: innerBoxIsScrolled,
      ),
    );
  }
}

/// 头部组件
class AnimeDetailHeader extends StatelessWidget {
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;
  final VoidCallback? onPlayPressed;

  const AnimeDetailHeader({
    super.key,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景模糊图片
        AnimeDetailBackground(
          imageUrl: bangumiItem.images.bestUrl,
          isLoading: isLoading,
        ),
        // 前景内容布局
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                kToolbarHeight,
                16,
                0,
              ),
              child: Column(
                children: [
                  BangumiInfoCard(
                    bangumiItem: bangumiItem,
                    isLoading: isLoading,
                    maxWidth: maxWidth,
                  ),
                  // 播放按钮区域
                  AnimePlayButton(
                    onPressed: onPlayPressed ?? () {
                      // 默认实现
                      print('开始观看');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 背景图片组件
class AnimeDetailBackground extends StatelessWidget {
  final String imageUrl;
  final bool isLoading;

  const AnimeDetailBackground({
    super.key,
    required this.imageUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      bottom: kTextTabBarHeight + 60, // 增加60px为播放按钮留空间
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.8, 1],
                    ).createShader(bounds);
                  },
                  child: _buildNetworkImage(
                    imageUrl,
                    boxConstraints.maxWidth,
                    boxConstraints.maxHeight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 网络图片构建
  Widget _buildNetworkImage(String imageUrl, double width, double height) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.movie, size: 80, color: Colors.white24),
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.movie, size: 80, color: Colors.white24),
        ),
      ),
    );
  }
}

/// 标签栏组件
class AnimeDetailTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> tabs;
  final bool innerBoxIsScrolled;

  const AnimeDetailTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kTextTabBarHeight),
      child: Container(
        color: innerBoxIsScrolled ? Colors.white : Colors.transparent,
        child: TabBar(
          controller: tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.center,
          dividerHeight: 0,
          labelColor: innerBoxIsScrolled ? Colors.black : Colors.black,
          unselectedLabelColor: innerBoxIsScrolled ? Colors.black : Colors.black,
          indicatorColor: innerBoxIsScrolled
              ? Theme.of(context).primaryColor
              : Colors.black26,
          tabs: tabs.map((name) => Tab(text: name)).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// 信息卡片组件
class BangumiInfoCard extends StatelessWidget {
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;

  const BangumiInfoCard({
    super.key,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: MediaQuery.sizeOf(context).width > maxWidth
          ? maxWidth
          : MediaQuery.sizeOf(context).width - 32,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧封面图片
          _buildCoverImage(),
          const SizedBox(width: 12),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: _buildAnimeInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(53),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          height: 230,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: bangumiItem.images.bestUrl.isNotEmpty
              ? Image.network(
                  bangumiItem.images.bestUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderIcon(),
                )
              : _buildPlaceholderIcon(),
        ),
      ),
    );
  }

  Widget _buildAnimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          bangumiItem.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // 放送日期和话数
        Text(
          '${bangumiItem.date} · 全 ${bangumiItem.totalEpisodes} 话',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),

        // 评分区域
        if (bangumiItem.rating != null) ...[
          Row(
            children: [
              // 评分星星
              ...List.generate(5, (index) {
                final score = bangumiItem.rating!.score;
                final fullStars = (score / 2).floor();
                final hasHalfStar = (score / 2) - fullStars >= 0.5;

                if (index < fullStars) {
                  return const Icon(Icons.star, color: Colors.amber, size: 20);
                } else if (index == fullStars && hasHalfStar) {
                  return const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 20,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: Colors.white54,
                    size: 16,
                  );
                }
              }),
              const SizedBox(width: 8),
              Text(
                bangumiItem.scoreText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            '${bangumiItem.totalRatingCount} 人评分 / #${bangumiItem.rating!.rank}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],

        const SizedBox(height: 12),

        // 收藏数据
        if (bangumiItem.collection != null) ...[
          Text(
            '${bangumiItem.totalCollectionCount} 收藏 / ${bangumiItem.collection!.doing} 在看 / ${bangumiItem.collection!.wish} 想看',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[400],
      child: const Icon(Icons.movie, size: 40, color: Colors.white),
    );
  }
}

/// 按钮组件
class AnimePlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AnimePlayButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          // 新增的左侧按钮
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: 处理左侧按钮点击事件
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 左侧按钮颜色
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: Colors.grey.withAlpha(53),
              ),
              icon: const Icon(Icons.add_chart_rounded, size: 20), // 左侧图标
              label: const Text(
                '追番',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10), // 按钮之间的间距

          // 开始观看按钮
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoInfoPage(
                      // 使用更兼容的测试视频URL
                      videoUrl: 'https://h6uzb5wdvs.senhewenhua.com:8080/cache/6IOG5aSn5YWaIOesrOS6jOWtoy1FUDQubXA0.mp4?verify=1753373198-l%2BCTHgbtzuQMvqXImHf%2FdagKqcqCRDJQeVROu4sU10s%3D',
                      videoTitle: '测试视频 - Big Buck Bunny',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6), // 紫色背景
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF8B5CF6).withAlpha(53),
              ),
              icon: const Icon(
                Icons.play_arrow_rounded,
                size: 24,
              ),
              label: const Text(
                '开始观看',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


