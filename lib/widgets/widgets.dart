import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/post.dart';

// ─── Author Avatar ───────────────────────────────────────────────────────────
class AuthorAvatar extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;

  const AuthorAvatar({
    super.key,
    required this.initials,
    required this.colorIndex,
    this.size = 44,
  });

  static const List<Color> _colors = [
    Color(0xFF4361EE),
    Color(0xFF7B2FBE),
    Color(0xFF06D6A0),
    Color(0xFFFF6B35),
    Color(0xFFFFBE0B),
    Color(0xFFEF233C),
    Color(0xFF4CC9F0),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[colorIndex % _colors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.35,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'published':
        bg = AppTheme.successGreen.withOpacity(0.15);
        fg = AppTheme.successGreen;
        icon = Icons.check_circle_rounded;
        break;
      case 'draft':
        bg = AppTheme.warningAmber.withOpacity(0.15);
        fg = const Color(0xFFB45309);
        icon = Icons.edit_rounded;
        break;
      case 'archived':
        bg = AppTheme.textSecondary.withOpacity(0.12);
        fg = AppTheme.textSecondary;
        icon = Icons.archive_rounded;
        break;
      default:
        bg = AppTheme.primaryBlue.withOpacity(0.12);
        fg = AppTheme.primaryBlue;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String category;

  const CategoryChip({super.key, required this.category});

  static const Map<String, Color> _catColors = {
    'News': Color(0xFF4361EE),
    'Tech': Color(0xFF7B2FBE),
    'Sports': Color(0xFF06D6A0),
    'Health': Color(0xFFFF6B35),
    'Culture': Color(0xFFFFBE0B),
    'Business': Color(0xFFEF233C),
    'Other': Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[category] ?? AppTheme.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AuthorAvatar(
                    initials: post.authorInitials,
                    colorIndex: post.authorColorIndex,
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _timeAgo(post.updatedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 16, color: AppTheme.primaryBlue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                size: 16, color: AppTheme.errorRed),
                            const SizedBox(width: 8),
                            Text('Delete',
                                style:
                                    TextStyle(color: AppTheme.errorRed)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CategoryChip(category: post.category),
                  const SizedBox(width: 8),
                  StatusBadge(status: post.status),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Tab ───────────────────────────────────────────────────────────────
class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.article_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first post',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
