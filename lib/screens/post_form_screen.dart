import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _authorCtrl;
  String _category = 'News';
  String _status = 'draft';
  int _colorIndex = 0;
  bool _isSaving = false;

  bool get _isEditing => widget.post != null;

  final List<String> _categories = [
    'News', 'Tech', 'Sports', 'Health', 'Culture', 'Business', 'Other'
  ];
  final List<String> _statuses = ['draft', 'published', 'archived'];

  static const List<Color> _avatarColors = [
    Color(0xFF4361EE),
    Color(0xFF7B2FBE),
    Color(0xFF06D6A0),
    Color(0xFFFF6B35),
    Color(0xFFFFBE0B),
    Color(0xFFEF233C),
    Color(0xFF4CC9F0),
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.post?.content ?? '');
    _authorCtrl = TextEditingController(text: widget.post?.authorName ?? '');
    _category = widget.post?.category ?? 'News';
    _status = widget.post?.status ?? 'draft';
    _colorIndex = widget.post?.authorColorIndex ?? 0;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final post = Post(
      id: widget.post?.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      category: _category,
      status: _status,
      authorName: _authorCtrl.text.trim(),
      authorInitials: _getInitials(_authorCtrl.text),
      authorColorIndex: _colorIndex,
      createdAt: widget.post?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      await DatabaseHelper.instance.updatePost(post);
    } else {
      await DatabaseHelper.instance.insertPost(post);
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Post updated!' : 'Post created!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 75, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Edit Post' : 'New Post',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _isEditing
                                ? 'Update your post content'
                                : 'Create and store locally',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Author Preview ──────────────────────────────────
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
                            initials: _getInitials(_authorCtrl.text),
                            colorIndex: _colorIndex,
                            size: 52,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _authorCtrl.text.isEmpty
                                      ? 'Author Name'
                                      : _authorCtrl.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _authorCtrl.text.isEmpty
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Color selector
                          Row(
                            children: List.generate(
                              _avatarColors.length,
                              (i) => GestureDetector(
                                onTap: () => setState(() => _colorIndex = i),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _avatarColors[i],
                                    shape: BoxShape.circle,
                                    border: _colorIndex == i
                                        ? Border.all(
                                            color: Colors.white, width: 2)
                                        : null,
                                    boxShadow: _colorIndex == i
                                        ? [
                                            BoxShadow(
                                              color: _avatarColors[i]
                                                  .withOpacity(0.5),
                                              blurRadius: 6,
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Author Name ─────────────────────────────────────
                    _label('Author Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _authorCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Sarah Johnson',
                        prefixIcon:
                            Icon(Icons.person_rounded, color: AppTheme.textSecondary),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Title ────────────────────────────────────────────
                    _label('Post Title'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Enter a compelling headline...',
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppTheme.textSecondary),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter a title'
                          : v.trim().length < 5
                              ? 'Title too short'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Content ──────────────────────────────────────────
                    _label('Content'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Write your post content here...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter content'
                          : v.trim().length < 20
                              ? 'Content too short (min 20 chars)'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Category ─────────────────────────────────────────
                    _label('Category'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? AppTheme.primaryGradient
                                  : null,
                              color: selected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppTheme.primaryBlue.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Status ───────────────────────────────────────────
                    _label('Status'),
                    const SizedBox(height: 10),
                    Row(
                      children: _statuses.map((s) {
                        final selected = _status == s;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _status = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: selected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : const Color(0xFFE5E7EB),
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    s == 'draft'
                                        ? Icons.edit_rounded
                                        : s == 'published'
                                            ? Icons.check_circle_rounded
                                            : Icons.archive_rounded,
                                    size: 18,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s[0].toUpperCase() + s.substring(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // ── Save Button ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ).copyWith(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isEditing
                                            ? Icons.save_rounded
                                            : Icons.add_circle_rounded,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _isEditing
                                            ? 'Save Changes'
                                            : 'Create Post',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }
}
