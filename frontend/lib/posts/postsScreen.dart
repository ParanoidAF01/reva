import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/service_manager.dart';

// ...existing code continues with the new StatefulWidget implementation
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoString;
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedBadge;
  List<dynamic> _posts = [];
  List<bool> _likedPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ServiceManager.instance.posts.getAllPosts();
      if (response['success'] == true) {
        final List<dynamic> postsData = response['data']['posts'] ?? [];
        setState(() {
          _posts = postsData;
          _likedPosts = List.generate(_posts.length, (index) => false);
          _loading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load posts';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredPosts {
    return _posts.where((post) {
      final matchesSearch = _searchText.isEmpty || (post['name'] as String).toLowerCase().contains(_searchText.toLowerCase()) || (post['role'] as String).toLowerCase().contains(_searchText.toLowerCase()) || (post['text'] ?? '').toLowerCase().contains(_searchText.toLowerCase());
      final matchesBadge = _selectedBadge == null || post['badge'] == _selectedBadge;
      return matchesSearch && matchesBadge;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.06),
                        // Top Bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2B2F34),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      const Icon(Icons.search, color: Colors.white54, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(color: Colors.white),
                                          cursorColor: Colors.white54,
                                          decoration: const InputDecoration(
                                            hintText: 'Search...',
                                            hintStyle: TextStyle(color: Colors.white54),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _searchText = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0262AB),
                                      Color(0xFF01345A)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchText = _searchController.text;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 22),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    'Search',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Simple filter dropdown
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: const Color(0xFF2B2F34),
                                  value: _selectedBadge,
                                  hint: const Text('Filter', style: TextStyle(color: Colors.white54)),
                                  icon: const Icon(Icons.filter_list, color: Colors.white),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All', style: GoogleFonts.dmSans(color: Colors.white)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'silver',
                                      child: Row(children: [
                                        Image.asset('assets/silverpostbadge.png', height: 16),
                                        const SizedBox(width: 6),
                                        Text('Silver', style: GoogleFonts.dmSans(color: Colors.white))
                                      ]),
                                    ),
                                    DropdownMenuItem(
                                      value: 'bronze',
                                      child: Row(children: [
                                        Image.asset('assets/bronzepostbadge.png', height: 16),
                                        const SizedBox(width: 6),
                                        Text('Bronze', style: GoogleFonts.dmSans(color: Colors.white))
                                      ]),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedBadge = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.025),
                        // ...removed Likes this row, posts will show as in screenshot 2
                        // Dynamic post cards
                        ..._filteredPosts.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final post = entry.value;
                          final author = post['author'] ?? {};
                          // Debug: print author object to verify structure
                          // ignore: avoid_print
                          print('Post author: ' + author.toString());
                          final comments = post['comments'] ?? [];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.012),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23262B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.blueGrey,
                                        backgroundImage: (author['profilePicture'] != null && author['profilePicture'].toString().isNotEmpty) ? NetworkImage(author['profilePicture']) : null,
                                        child: (author['profilePicture'] == null || author['profilePicture'].toString().isEmpty)
                                            ? Text(
                                                (author['fullName'] != null && author['fullName'].isNotEmpty)
                                                    ? author['fullName'][0].toUpperCase()
                                                    : (author['name'] != null && author['name'].isNotEmpty)
                                                        ? author['name'][0].toUpperCase()
                                                        : '?',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(author['fullName'] ?? 'Unknown', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                                            Text(post['category'] ?? '', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                                            const SizedBox(height: 2),
                                            Text(_formatTimestamp(post['createdAt']), style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.more_horiz, color: Colors.white54),
                                    ],
                                  ),
                                  if (post['content'] != null) ...[
                                    const SizedBox(height: 10),
                                    Text(post['content'], style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15)),
                                  ],
                                  const SizedBox(height: 10),
                                  Text('${comments.length} comments', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13)),
                                  const SizedBox(height: 10),
                                  // Comments List
                                  // Dropdown to show/hide comments (per post)
                                  Builder(
                                    builder: (context) {
                                      post['showComments'] ??= false;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                post['showComments'] = !post['showComments'];
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  post['showComments'] ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                  color: Colors.white54,
                                                ),
                                                const SizedBox(width: 4),
                                                Text('View Comments', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          if (post['showComments'])
                                            Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 8),
                                              child: Column(
                                                children: List.generate(comments.length, (cIdx) {
                                                  final comment = comments[cIdx];
                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF2B2F34),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 14,
                                                          backgroundColor: Colors.blueGrey,
                                                          backgroundImage: (comment['author'] != null && comment['author']['profilePicture'] != null && comment['author']['profilePicture'].toString().isNotEmpty) ? NetworkImage(comment['author']['profilePicture']) : null,
                                                          child: (comment['author'] == null || comment['author']['profilePicture'] == null || comment['author']['profilePicture'].toString().isEmpty)
                                                              ? Text(
                                                                  comment['author'] != null && comment['author']['fullName'] != null && comment['author']['fullName'].isNotEmpty ? comment['author']['fullName'][0].toUpperCase() : '?',
                                                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                                                )
                                                              : null,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(comment['content'] ?? '', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  // Add Comment Input
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: post['commentController'] ??= TextEditingController(),
                                            decoration: InputDecoration(
                                              hintText: 'Add a comment...',
                                              hintStyle: GoogleFonts.dmSans(color: Colors.white54, fontSize: 13),
                                              filled: true,
                                              fillColor: const Color(0xFF2B2F34),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.send, color: Colors.white70, size: 20),
                                          onPressed: () async {
                                            final commentText = post['commentController'].text.trim();
                                            if (commentText.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Comment cannot be empty')),
                                              );
                                              return;
                                            }
                                            final response = await ServiceManager.instance.posts.addComment(
                                              post['_id'].toString(),
                                              {
                                                'content': commentText
                                              }, // Use 'content' as required by API
                                            );
                                            if (response['success'] == true) {
                                              setState(() {
                                                comments.add({
                                                  'content': commentText,
                                                  'author': {
                                                    'fullName': 'You'
                                                  }
                                                });
                                                post['commentController'].clear();
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(response['message'] ?? 'Failed to add comment')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final response = await ServiceManager.instance.posts.toggleLike(post['_id'].toString());
                                          if (response['success'] == true) {
                                            setState(() {
                                              if (idx < _likedPosts.length) {
                                                _likedPosts[idx] = !_likedPosts[idx];
                                              }
                                              // Optionally update like count from backend
                                              if (response['data'] != null && response['data']['likes'] != null) {
                                                post['likes'] = response['data']['likes'];
                                              }
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(response['message'] ?? 'Failed to like post')),
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              (idx < _likedPosts.length && _likedPosts[idx]) ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                              color: (idx < _likedPosts.length && _likedPosts[idx]) ? Colors.white : Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text('Like', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                                            if (post['likes'] != null && post['likes'] is List && post['likes'].length > 0) ...[
                                              const SizedBox(width: 4),
                                              Text('(${post['likes'].length})', style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 12)),
                                            ]
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(Icons.mode_comment_outlined, 'Comment'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(Icons.share_outlined, 'Share'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(Icons.send_outlined, 'Send'),
                                      ),
                                    ],
                                  ),
// ...existing code...
                                ],
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: height * 0.03),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _postAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
