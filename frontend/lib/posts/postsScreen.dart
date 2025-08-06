import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/service_manager.dart';

final Map<String, TextEditingController> _commentControllers = {};

// ...existing code continues with the new StatefulWidget implementation
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  Map<String, dynamic> _profilesMap = {};

  @override
  void initState() {
    super.initState();
    fetchProfiles();
    fetchPosts();
  }

  Future<void> fetchProfiles() async {
    try {
      final response = await ServiceManager.instance.profile.getAllProfiles();
      if (response['success'] == true && response['data'] != null) {
        final profiles = response['data']['profiles'] ?? [];
        setState(() {
          _profilesMap = {
            for (var p in profiles) p['user']: p
          };
        });
      }
    } catch (e) {
      // ignore errors for now
    }
  }

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
  Map<String, bool> _showCommentsMap = {};
  Map<String, Set<String>> _likedCommentsMap = {};
  bool _loading = true;
  String? _error;

  // Removed duplicate initState

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
      final author = post['author'] ?? {};
      final authorName = (author['fullName'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchText.isEmpty || authorName.contains(_searchText.toLowerCase());
      final status = (author['status'] ?? '').toString().toLowerCase();
      final matchesBadge = _selectedBadge == null || status == _selectedBadge;
      return matchesSearch && matchesBadge;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading:  SizedBox(
        ),
        title: Text(
          "Posts",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
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
                                            hintText: 'Search by user name...',
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
                                    DropdownMenuItem(
                                      value: 'gold',
                                      child: Row(children: [
                                        Image.asset('assets/goldpostbadge.png', height: 16),
                                        const SizedBox(width: 6),
                                        Text('Gold', style: GoogleFonts.dmSans(color: Colors.white))
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
                          final comments = post['comments'] ?? [];
                          final badge = post['badge'] ?? 'silver';
                          final role = author['status'] ?? post['role'] ?? '';
                          final location = author['location'] ?? post['location'] ?? '';
                          final time = _formatTimestamp(post['createdAt']);
                          final postId = post['_id']?.toString() ?? idx.toString();
                          final showComments = _showCommentsMap[postId] ?? false;
                          final parsedComments = (post['comments'] as List).map((c) => c is Map<String, dynamic> ? c : {}).toList();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(width * 0.04),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E3339),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Likes row (optional, can be hidden if not needed)
                                  if (post['likes'] != null && post['likes'] is List && post['likes'].length > 0)
                                    Text(
                                      post['likes'].length == 1 ? "${post['likes'][0]['fullName']} likes this" : "${post['likes'][0]['fullName']} and ${post['likes'].length - 1} others like this",
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  if (post['likes'] != null && post['likes'] is List && post['likes'].length > 0) const Divider(color: Color(0xFFCED5DC), thickness: 2),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        backgroundImage: (author['profile'] != null && author['profile']['profilePicture'] != null && author['profile']['profilePicture'].toString().isNotEmpty)
                                            ? NetworkImage(author['profile']['profilePicture'])
                                            : (author['profilePicture'] != null && author['profilePicture'].toString().isNotEmpty)
                                                ? NetworkImage(author['profilePicture'])
                                                : null,
                                        child: ((author['profile'] == null || author['profile']['profilePicture'] == null || author['profile']['profilePicture'].toString().isEmpty) && (author['profilePicture'] == null || author['profilePicture'].toString().isEmpty)) ? Icon(Icons.person, color: Colors.black) : null,
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              author['fullName'] ?? 'Unknown',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "$role${location.isNotEmpty ? ", $location" : ""}",
                                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.public, size: 12, color: Colors.white60),
                                                const SizedBox(width: 4),
                                                Text(time, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Dynamic badge image based on status
                                      (() {
                                        String badgeStatus = (author['status'] ?? 'silver').toString().toLowerCase();
                                        String badgeAsset;
                                        if (badgeStatus == 'bronze') {
                                          badgeAsset = 'assets/bronze.png';
                                        } else if (badgeStatus == 'gold') {
                                          badgeAsset = 'assets/gold.png';
                                        } else {
                                          badgeAsset = 'assets/silver.png'; // Use attached image for silver
                                        }
                                        return Image.asset(badgeAsset, height: 32);
                                      })(),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Post text
                                  Text(
                                    post['content'] ?? post['text'] ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                  ),
                                  const SizedBox(height: 4),
                                  // Read more button (if text is long)
                                  if ((post['content'] ?? post['text'] ?? '').length > 120)
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text("read more", style: TextStyle(color: Colors.lightBlue, fontSize: 13.5)),
                                    ),
                                  // Images: single centered, multiple horizontal scroll
                                  if (post['images'] != null && post['images'] is List && post['images'].isNotEmpty)
                                    post['images'].length == 1
                                        ? Center(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(post['images'][0], height: 200, width: 200, fit: BoxFit.cover),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 200,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: post['images'].length,
                                              separatorBuilder: (context, i) => const SizedBox(width: 12),
                                              itemBuilder: (context, i) {
                                                final imgUrl = post['images'][i];
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(imgUrl, height: 200, width: 200, fit: BoxFit.cover),
                                                );
                                              },
                                            ),
                                          ),
                                  // Showcase videos
                                  if (post['videos'] != null && post['videos'] is List && post['videos'].isNotEmpty)
                                    SizedBox(
                                      height: 200,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: post['videos'].length,
                                        separatorBuilder: (context, i) => const SizedBox(width: 12),
                                        itemBuilder: (context, i) {
                                          final vidUrl = post['videos'][i];
                                          return Container(
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text('Video', style: TextStyle(color: Colors.white)),
                                            ),
                                          );
                                          // For real video preview, use a video player widget
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  // Comment count row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showCommentsMap[postId] = !(_showCommentsMap[postId] ?? false);
                                          });
                                        },
                                        child: Text(
                                          "${comments.length} comments",
                                          style: const TextStyle(color: Colors.white60, fontSize: 12, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Show all comments if toggled
                                  if (showComments)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        children: [
                                          if (parsedComments.isEmpty) Text('No comments yet.', style: TextStyle(color: Colors.white54)),
                                          ...parsedComments.map<Widget>((comment) {
                                            final user = comment['user'] ?? {};
                                            final userId = user['_id']?.toString() ?? user['user']?.toString() ?? '';
                                            final name = user['fullName'] ?? 'Unknown';
                                            String? profilePic;
                                            if (_profilesMap.containsKey(userId) && _profilesMap[userId]['profilePicture'] != null && _profilesMap[userId]['profilePicture'].toString().isNotEmpty) {
                                              profilePic = _profilesMap[userId]['profilePicture'];
                                            } else if (user['profile'] != null && user['profile']['profilePicture'] != null && user['profile']['profilePicture'].toString().isNotEmpty) {
                                              profilePic = user['profile']['profilePicture'];
                                            } else {
                                              profilePic = null;
                                            }
                                            final commentId = comment['_id']?.toString() ?? '';
                                            final liked = _likedCommentsMap[postId]?.contains(commentId) ?? false;
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                                                  child: profilePic == null ? Icon(Icons.person, color: Colors.black) : null,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                      Text(comment['content'] ?? '', style: const TextStyle(color: Colors.white70)),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      _likedCommentsMap[postId] ??= {};
                                                      if (liked) {
                                                        _likedCommentsMap[postId]!.remove(commentId);
                                                      } else {
                                                        _likedCommentsMap[postId]!.add(commentId);
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                    liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                                    color: liked ? Colors.white : Colors.white70,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                          // Only one comment input box below comments
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Add a comment...',
                                              hintStyle: TextStyle(color: Colors.white54),
                                              filled: true,
                                              fillColor: Color(0xFF2B2F34),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            style: TextStyle(color: Colors.white),
                                            controller: _commentControllers[postId] ??= TextEditingController(),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF4A90E2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final text = _commentControllers[postId]?.text.trim() ?? '';
                                            if (text.isEmpty) return;
                                            final response = await ServiceManager.instance.posts.addComment(postId, {
                                              'content': text
                                            });
                                            if (response['success'] == true) {
                                              setState(() {
                                                post['comments'] = response['data']['comments'];
                                                _commentControllers[postId]?.clear();
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(response['message'] ?? 'Failed to add comment')),
                                              );
                                            }
                                          },
                                          child: Text('Post', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(color: Colors.white, thickness: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final response = await ServiceManager.instance.posts.toggleLike(post['_id'].toString());
                                          if (response['success'] == true) {
                                            setState(() {
                                              // Get current user ID from token or context if available
                                              List<dynamic> likes = response['data']['likes'] ?? [];
                                              post['likes'] = likes;
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(response['message'] ?? 'Failed to like post')),
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            FutureBuilder<String?>(
                                              future: ServiceManager.instance.auth.getCurrentUserId(),
                                              builder: (context, snapshot) {
                                                final currentUserId = snapshot.data;
                                                final likes = post['likes'] ?? [];
                                                final isLiked = currentUserId != null && likes.any((like) => like['_id'] == currentUserId);
                                                return Icon(
                                                  isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                                  size: 20,
                                                  color: isLiked ? Colors.white : Colors.white70,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Like (${post['likes'] != null ? post['likes'].length : 0})',
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showCommentsMap[postId] = !(_showCommentsMap[postId] ?? false);
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Icon(Icons.mode_comment_outlined, size: 20, color: Colors.white70),
                                            const SizedBox(height: 4),
                                            Text('Comment', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: Column(
                                          children: [
                                            Icon(Icons.share_outlined, size: 20, color: Colors.white70),
                                            const SizedBox(height: 4),
                                            Text('Share', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: Column(
                                          children: [
                                            Icon(Icons.send_outlined, size: 20, color: Colors.white70),
                                            const SizedBox(height: 4),
                                            Text('Send', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

  // Removed unused _postAction widget
}
