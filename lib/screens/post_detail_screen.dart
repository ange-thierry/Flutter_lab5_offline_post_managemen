import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../database/database_helper.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _refresh() async {
    if (_post.id != null) {
      final updated = await DatabaseHelper.instance.getPost(_post.id!);
      if (updated != null && mounted) setState(() => _post = updated);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Are you sure? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
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
    if (confirm == true && _post.id != null && mounted) {
      await DatabaseHelper.instance.deletePost(_post.id!);
      Navigator.pop(context);
    }
  }

  String _formatFull(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} · $h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostFormScreen(post: _post),
                    ),
                  );
                  _refresh();
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              IconButton(
                onPressed: _delete,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CategoryChip(category: _post.category),
                              const SizedBox(width: 8),
                              StatusBadge(status: _post.status),
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

          // ── Post Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Author info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AuthorAvatar(
                          initials: _post.authorInitials,
                          colorIndex: _post.authorColorIndex,
                          size: 50,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post.authorName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Published ${_formatFull(_post.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with label
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Content',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Body text
                  Text(
                    _post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      height: 1.75,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Metadata card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _metaRow(Icons.calendar_today_rounded, 'Created',
                            _formatFull(_post.createdAt)),
                        const Divider(height: 20),
                        _metaRow(Icons.update_rounded, 'Last Updated',
                            _formatFull(_post.updatedAt)),
                        const Divider(height: 20),
                        _metaRow(Icons.label_rounded, 'Category', _post.category),
                        const Divider(height: 20),
                        _metaRow(Icons.toggle_on_rounded, 'Status',
                            _post.status[0].toUpperCase() + _post.status.substring(1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Edit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostFormScreen(post: _post),
                          ),
                        );
                        _refresh();
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit Post'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: const Text('Delete Post',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }
}
