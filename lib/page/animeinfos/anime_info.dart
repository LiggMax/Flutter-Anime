import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';
import 'package:flutter_app/modules/bangumi_data.dart';
import 'anime_head.dart';

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

class _AnimeDataPageState extends State<AnimeDataPage>
    with TickerProviderStateMixin {
  /// 控制器模式
  final InfoController infoController = InfoController();
  late TabController infoTabController;

  bool commentsIsLoading = false;
  bool charactersIsLoading = false;
  bool commentsQueryTimeout = false;
  bool charactersQueryTimeout = false;

  // 响应式布局常量
  final double maxWidth = 950.0;

  @override
  void initState() {
    super.initState();
    // 初始化数据 创建空的BangumiDetailData实例
    infoController.bangumiItem = BangumiDetailData(
      id: widget.animeId,
      name: '',
      nameCn: widget.animeName ?? '动漫详情',
      summary: '',
      date: '',
      platform: '',
      images: BangumiImages(
        small: widget.imageUrl ?? '',
        grid: widget.imageUrl ?? '',
        large: widget.imageUrl ?? '',
        medium: widget.imageUrl ?? '',
        common: widget.imageUrl ?? '',
      ),
      rating: null,
      collection: null,
      tags: [],
      infobox: [],
      metaTags: [],
      totalEpisodes: 0,
      eps: 0,
      volumes: 0,
      type: 2, // 默认为TV动画
      series: false,
      locked: false,
      nsfw: false,
    );

    // 标签页设置
    infoTabController = TabController(length: 2, vsync: this);

    // 加载详情数据
    queryBangumiInfoByID(widget.animeId);
  }

  @override
  void dispose() {
    infoTabController.dispose();
    super.dispose();
  }

  /// 查询方法
  Future<void> queryBangumiInfoByID(int id, {String type = "init"}) async {
    try {
      await infoController.queryBangumiInfoByID(id, type: type);
      setState(() {});
    } catch (e) {
      print('Error loading anime data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 标签页配置
    final List<String> tabs = <String>['详情', '简介'];

    return PopScope(
      canPop: true,
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: AnimeDetailAppBar(
                    title: infoController.bangumiItem.displayName.isEmpty
                        ? (widget.animeName ?? '动漫详情')
                        : infoController.bangumiItem.displayName,
                    innerBoxIsScrolled: innerBoxIsScrolled,
                    tabController: infoTabController,
                    tabs: tabs,
                    background: AnimeDetailHeader(
                      bangumiItem: infoController.bangumiItem,
                      isLoading: infoController.isLoading,
                      maxWidth: maxWidth,
                      onPlayPressed: () {
                        // TODO 条转播放页

                      },
                    ),
                  ),
                ),
              ];
            },
            body: AnimeInfoTabView(
              tabController: infoTabController,
              bangumiItem: infoController.bangumiItem,
              isLoading: infoController.isLoading,
              maxWidth: maxWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// 控制器模式
class InfoController {
  late BangumiDetailData bangumiItem;
  bool isLoading = false;

  Future<void> queryBangumiInfoByID(int id, {String type = "init"}) async {
    isLoading = true;
    try {
      final data = await BangumiService.getInfoByID(id);
      if (data != null) {
        final parsedData = BangumiDataParser.parseDetailData(data);
        if (parsedData != null) {
          // 直接替换整个对象，因为字段是final的
          bangumiItem = parsedData;
        }
      }
    } catch (e) {
      print('Error in queryBangumiInfoByID: $e');
    } finally {
      isLoading = false;
    }
  }
}

/// 标签页视图组件
class AnimeInfoTabView extends StatefulWidget {
  const AnimeInfoTabView({
    super.key,
    required this.tabController,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
  });

  final TabController tabController;
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;

  @override
  State<AnimeInfoTabView> createState() => _AnimeInfoTabViewState();
}

class _AnimeInfoTabViewState extends State<AnimeInfoTabView>
    with SingleTickerProviderStateMixin {
  bool fullIntro = false;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [_buildDetailInfoTab(), _buildSummaryTab()],
    );
  }

  /// 详情标签页
  Widget _buildDetailInfoTab() {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          key: const PageStorageKey<String>('详情'),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                bottom: false,
                child: _buildDetailInfoContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 简介标签页
  Widget _buildSummaryTab() {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          key: const PageStorageKey<String>('简介'),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                bottom: false,
                child: _buildSummaryContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 详情内容实现
  Widget _buildDetailInfoContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > widget.maxWidth
              ? widget.maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection('基本信息', [
                _buildInfoRow('原名', widget.bangumiItem.name),
                _buildInfoRow('中文名', widget.bangumiItem.nameCn),
                _buildInfoRow('类型', widget.bangumiItem.typeText),
                _buildInfoRow('总集数', '${widget.bangumiItem.totalEpisodes}话'),
                _buildInfoRow('放送日期', widget.bangumiItem.date),
                _buildInfoRow('播放平台', widget.bangumiItem.platform),
              ]),

              const SizedBox(height: 20),

              _buildInfoSection('评分信息', [
                _buildInfoRow('评分', widget.bangumiItem.scoreText),
                _buildInfoRow(
                  '评价人数',
                  '${widget.bangumiItem.totalRatingCount}人',
                ),
                if (widget.bangumiItem.rating != null)
                  _buildInfoRow('排名', '第${widget.bangumiItem.rating!.rank}名'),
              ]),

              const SizedBox(height: 20),

              if (widget.bangumiItem.collection != null) ...[
                _buildInfoSection('收藏信息', [
                  _buildInfoRow(
                    '总收藏',
                    '${widget.bangumiItem.totalCollectionCount}人',
                  ),
                  _buildInfoRow(
                    '想看',
                    '${widget.bangumiItem.collection!.wish}人',
                  ),
                  _buildInfoRow(
                    '在看',
                    '${widget.bangumiItem.collection!.doing}人',
                  ),
                  _buildInfoRow(
                    '看过',
                    '${widget.bangumiItem.collection!.collect}人',
                  ),
                  _buildInfoRow(
                    '搁置',
                    '${widget.bangumiItem.collection!.onHold}人',
                  ),
                  _buildInfoRow(
                    '抛弃',
                    '${widget.bangumiItem.collection!.dropped}人',
                  ),
                ]),

                const SizedBox(height: 20),
              ],

              if (widget.bangumiItem.mainTags.isNotEmpty) ...[
                _buildInfoSection('标签', [
                  _buildTagsRow(widget.bangumiItem.mainTags),
                ]),
              ],

              // 底部间距
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// 简介内容实现，包含智能展开功能
  Widget _buildSummaryContent() {
    if (widget.bangumiItem.summary.isEmpty) {
      return const Center(
        child: Text('暂无简介', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    // 处理换行符和格式化文本
    final formattedSummary = widget.bangumiItem.summary
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > widget.maxWidth
              ? widget.maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('简介', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              // 展开/收起功能
              LayoutBuilder(
                builder: (context, constraints) {
                  final span = TextSpan(text: formattedSummary);
                  final tp = TextPainter(
                    text: span,
                    textDirection: TextDirection.ltr,
                  );
                  tp.layout(maxWidth: constraints.maxWidth);
                  final numLines = tp.computeLineMetrics().length;

                  if (numLines > 7) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: fullIntro ? null : 120,
                          width:
                              MediaQuery.sizeOf(context).width > widget.maxWidth
                              ? widget.maxWidth
                              : MediaQuery.sizeOf(context).width - 32,
                          child: SelectableText(
                            formattedSummary,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              fullIntro = !fullIntro;
                            });
                          },
                          child: Text(fullIntro ? '加载更少' : '加载更多'),
                        ),
                      ],
                    );
                  } else {
                    return SelectableText(
                      formattedSummary,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    );
                  }
                },
              ),

              // 底部间距
              const SizedBox(height: 100),
            ],
          ),
        ),
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
          child: Column(children: children),
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withAlpha(52)),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
