import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offline_posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        authorName TEXT NOT NULL,
        authorInitials TEXT NOT NULL,
        authorColorIndex INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Insert sample data
    final now = DateTime.now();
    final samplePosts = [
      {
        'title': 'Breaking: Company Wins Regional Award',
        'content':
            'Our media company has been recognized as the best regional outlet for investigative journalism. The award ceremony was held at the Grand Hotel downtown, attended by over 300 media professionals.\n\nThe judges praised our commitment to factual reporting and our innovative digital-first approach to storytelling. Our editor-in-chief accepted the award on behalf of the entire team.',
        'category': 'News',
        'status': 'published',
        'authorName': 'Sarah Johnson',
        'authorInitials': 'SJ',
        'authorColorIndex': 0,
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'title': 'Interview: Tech CEO on the Future of AI',
        'content':
            'In an exclusive interview, the CEO of TechVision shared insights on artificial intelligence and how it will reshape the media landscape over the next decade.\n\n"We believe AI will be a tool for journalists, not a replacement," she stated confidently during our hour-long conversation.',
        'category': 'Tech',
        'status': 'published',
        'authorName': 'Michael Osei',
        'authorInitials': 'MO',
        'authorColorIndex': 1,
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'title': 'Sports Round-up: Weekend Results',
        'content':
            'This weekend saw thrilling action across multiple sports arenas. The local football team secured a decisive 3-1 victory in the regional championship qualifier, while the basketball team narrowly lost in overtime.\n\nOur correspondent on the ground reports that the stadium was at full capacity for the first time this season.',
        'category': 'Sports',
        'status': 'draft',
        'authorName': 'Amara Diallo',
        'authorInitials': 'AD',
        'authorColorIndex': 2,
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(hours: 6)).toIso8601String(),
      },
      {
        'title': 'Health Advisory: Rainy Season Precautions',
        'content':
            'The Ministry of Health has issued updated guidelines for the ongoing rainy season. Citizens are advised to maintain clean surroundings, use mosquito nets, and seek immediate medical attention if symptoms of malaria or typhoid appear.\n\nLocal health centers will offer free screening throughout the month.',
        'category': 'Health',
        'status': 'published',
        'authorName': 'Dr. Paul Kagame Jr.',
        'authorInitials': 'PK',
        'authorColorIndex': 3,
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'title': 'Cultural Festival Recap: Colors & Music',
        'content':
            'The annual cultural festival brought thousands together in a vibrant celebration of music, food, and tradition. Artists from 12 different regions performed over the three-day event.\n\nThis year\'s theme "Unity in Diversity" resonated with attendees who travelled from across the country to participate.',
        'category': 'Culture',
        'status': 'archived',
        'authorName': 'Lena Uwase',
        'authorInitials': 'LU',
        'authorColorIndex': 4,
        'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 14)).toIso8601String(),
      },
    ];

    for (final post in samplePosts) {
      await db.insert('posts', post);
    }
  }

  // CREATE
  Future<int> insertPost(Post post) async {
    final db = await instance.database;
    return await db.insert('posts', post.toMap());
  }

  // READ ALL
  Future<List<Post>> getAllPosts() async {
    final db = await instance.database;
    final result = await db.query('posts', orderBy: 'updatedAt DESC');
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // READ ONE
  Future<Post?> getPost(int id) async {
    final db = await instance.database;
    final maps = await db.query('posts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Post.fromMap(maps.first);
    }
    return null;
  }

  // READ BY STATUS
  Future<List<Post>> getPostsByStatus(String status) async {
    final db = await instance.database;
    final result = await db.query(
      'posts',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'updatedAt DESC',
    );
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // SEARCH
  Future<List<Post>> searchPosts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'posts',
      where: 'title LIKE ? OR content LIKE ? OR authorName LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return result.map((map) => Post.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updatePost(Post post) async {
    final db = await instance.database;
    return await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // DELETE
  Future<int> deletePost(int id) async {
    final db = await instance.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // COUNT by status
  Future<Map<String, int>> getPostCounts() async {
    final db = await instance.database;
    final total = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM posts'),
        ) ??
        0;
    final published = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM posts WHERE status = ?', ['published']),
        ) ??
        0;
    final draft = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM posts WHERE status = ?', ['draft']),
        ) ??
        0;
    final archived = Sqflite.firstIntValue(
          await db.rawQuery(
              'SELECT COUNT(*) FROM posts WHERE status = ?', ['archived']),
        ) ??
        0;
    return {
      'total': total,
      'published': published,
      'draft': draft,
      'archived': archived,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
