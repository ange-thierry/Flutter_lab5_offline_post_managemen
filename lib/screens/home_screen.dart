import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Post> _posts = [];
  Map<String, int> _counts = {'total': 0, 'published': 0, 'draft': 0, 'archived': 0};
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnim;

  final List<String> _filters = ['All', 'Published', 'Draft', 'Archived'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadData();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final posts = _selectedFilter == 'All'
        ? await DatabaseHelper.instance.getAllPosts()
        : await DatabaseHelper.instance
            .getPostsByStatus(_selectedFilter.toLowerCase());
    final counts = await DatabaseHelper.instance.getPostCounts();
    setState(() {
      _posts = posts;
      _counts = counts;
      _isLoading = false;
    });
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      _loadData();
      return;
    }
    final results = await DatabaseHelper.instance.searchPosts(q);
    setState(() => _posts = results);
  }

  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to delete "${post.title}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && post.id != null) {
      await DatabaseHelper.instance.deletePost(post.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post deleted'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 60,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 70, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.newspaper_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Offline Posts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    'Manager',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() => _isSearching = !_isSearching);
                                  if (!_isSearching) {
                                    _searchController.clear();
                                    _loadData();
                                  }
                                },
                                icon: Icon(
                                  _isSearching
                                      ? Icons.close_rounded
                                      : Icons.search_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stat row
                          Row(
                            children: [
                              _miniStat('${_counts['total']}', 'Total',
                                  Icons.article_rounded),
                              const SizedBox(width: 12),
                              _miniStat('${_counts['published']}', 'Live',
                                  Icons.check_circle_rounded),
                              const SizedBox(width: 12),
                              _miniStat('${_counts['draft']}', 'Draft',
                                  Icons.edit_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search Bar ───────────────────────────────────────────────────
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Search posts, authors...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _loadData();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

          // ── Filter Tabs ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterTab(
                              label: f,
                              isSelected: _selectedFilter == f,
                              onTap: () {
                                setState(() => _selectedFilter = f);
                                _loadData();
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              ),
            )
          else if (_posts.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                message: _isSearching
                    ? 'No posts match your search'
                    : 'No ${_selectedFilter == 'All' ? '' : _selectedFilter} posts yet',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final post = _posts[i];
                  return PostCard(
                    post: post,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post),
                        ),
                      );
                      _loadData();
                    },
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostFormScreen(post: post),
                        ),
                      );
                      _loadData();
                    },
                    onDelete: () => _deletePost(post),
                  );
                },
                childCount: _posts.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostFormScreen()),
            );
            _loadData();
          },
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'New Post',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
