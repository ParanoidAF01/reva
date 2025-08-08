import 'package:flutter/material.dart';
import 'package:reva/shared/network_error_overlay.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/service_manager.dart';

final Map<String, TextEditingController> _commentControllers = {};

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  String? _currentUserId;
  Map<String, dynamic> _profilesMap = {};
  Map<String, dynamic>? _myProfile;
  bool _loading = true;
  String? _error;
  List<dynamic> _posts = [];
  Map<String, bool> _showCommentsMap = {};
  Map<String, Set<String>> _likedCommentsMap = {};
  Map<String, bool> _expandedPosts = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedBadge;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchProfiles();
    await fetchMyProfile();
    await fetchPosts();
    final id = await ServiceManager.instance.auth.getCurrentUserId();
    setState(() {
      _currentUserId = id;
    });
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
      // Handle errors silently or log
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      final response = await ServiceManager.instance.profile.getMyProfile();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _myProfile = response['data'];
        });
      }
    } catch (e) {
      // Handle errors silently or log
    }
  }

  Future<void> fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ServiceManager.instance.posts.getAllPosts();
      if (response['success'] == true) {
        final postsData = response['data']['posts'] ?? [];
        setState(() {
          _posts = postsData;
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

  String _truncateName(String name, [int maxLength = 14]) {
    if (name.length > maxLength) return name.substring(0, maxLength) + '...';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return NetworkErrorOverlay(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF22252A),
          elevation: 0,
          leading: const SizedBox(),
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.01),

                            // Search and filter bar
                            Row(
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

                            SizedBox(height: height * 0.025),

                            // Posts List
                            ..._filteredPosts.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final post = entry.value;
                              final author = post['author'] ?? {};
                              final comments = post['comments'] ?? [];
                              final role = author['status'] ?? post['role'] ?? '';
                              final location = author['location'] ?? post['location'] ?? '';
                              final time = _formatTimestamp(post['createdAt']);
                              final postId = post['_id']?.toString() ?? idx.toString();
                              final showComments = _showCommentsMap[postId] ?? false;
                              final contentText = post['content'] ?? post['text'] ?? '';
                              final isExpanded = _expandedPosts[postId] ?? false;

                              final parsedComments = (post['comments'] as List).map((c) => c is Map<String, dynamic> ? c : {}).toList();

                              // Likes display with truncation:
                              String likesText = '';
                              final likesList = (post['likes'] is List) ? post['likes'] : [];
                              if (likesList.isNotEmpty) {
                                if (likesList.length == 1) {
                                  likesText = '${_truncateName(likesList[0]['fullName'] ?? '')} likes this';
                                } else if (likesList.length == 2) {
                                  likesText = '${_truncateName(likesList[0]['fullName'] ?? '')} and ${_truncateName(likesList[1]['fullName'] ?? '')} like this';
                                } else {
                                  final truncatedNames = likesList.take(likesList.length - 1).map<String>((like) => _truncateName(like['fullName'] ?? '')).toList();
                                  likesText = '${truncatedNames.join(', ')} and ${_truncateName(likesList.last['fullName'] ?? '')} like this';
                                }
                              }

                              // Badge asset selection
                              String badgeStatus = role.toLowerCase();
                              String badgeAsset;
                              if (badgeStatus == 'bronze') {
                                badgeAsset = 'assets/bronze.png';
                              } else if (badgeStatus == 'gold') {
                                badgeAsset = 'assets/gold.png';
                              } else {
                                badgeAsset = 'assets/silverpostbadge.png';
                              }

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
                                      if (likesText.isNotEmpty)
                                        Text(
                                          likesText,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (likesText.isNotEmpty) const Divider(color: Color(0xFFCED5DC), thickness: 2),

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
                                            child: ((author['profile'] == null || author['profile']['profilePicture'] == null || author['profile']['profilePicture'].toString().isEmpty) && (author['profilePicture'] == null || author['profilePicture'].toString().isEmpty)) ? const Icon(Icons.person, color: Colors.black) : null,
                                          ),
                                          SizedBox(width: width * 0.03),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (author['fullName'] ?? 'Unknown').toString().length > 15 ? (author['fullName'] ?? 'Unknown').toString().substring(0, 15) + '...' : (author['fullName'] ?? 'Unknown').toString(),
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                                          Image.asset(badgeAsset, height: 32),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Post content with truncation and toggle
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contentText,
                                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                            maxLines: isExpanded ? null : 5,
                                            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                          ),
                                          if (contentText.length > 120)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _expandedPosts[postId] = !isExpanded;
                                                });
                                              },
                                              child: Text(
                                                isExpanded ? "show less" : "read more",
                                                style: const TextStyle(color: Colors.lightBlue, fontSize: 13.5),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      // Images section
                                      if (post['images'] != null && post['images'] is List && (post['images'] as List).isNotEmpty)
                                        (post['images'] as List).length == 1
                                            ? SizedBox(
                                                width: double.infinity,
                                                child: Image.network(
                                                  post['images'][0],
                                                  height: 220,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : SizedBox(
                                                height: 220,
                                                child: ListView.separated(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: post['images'].length,
                                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                                  itemBuilder: (context, i) {
                                                    return Image.network(
                                                      post['images'][i],
                                                      height: 220,
                                                      width: MediaQuery.of(context).size.width * 0.7,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                              ),

                                      // Videos placeholder
                                      if (post['videos'] != null && post['videos'] is List && (post['videos'] as List).isNotEmpty)
                                        SizedBox(
                                          height: 200,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: post['videos'].length,
                                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                                            itemBuilder: (context, i) {
                                              return Container(
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Center(
                                                  child: Text('Video', style: TextStyle(color: Colors.white)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      const SizedBox(height: 10),

                                      // Comments count and toggle
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _showCommentsMap[postId] = !(showComments);
                                              });
                                            },
                                            child: Text(
                                              "${comments.length} comments",
                                              style: const TextStyle(color: Colors.white60, fontSize: 12, decoration: TextDecoration.underline),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Comments section (expanded)
                                      if (showComments)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            children: [
                                              if (parsedComments.isEmpty) const Text('No comments yet.', style: TextStyle(color: Colors.white54)),
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
                                                      child: profilePic == null ? const Icon(Icons.person, color: Colors.black) : null,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            _truncateName(name),
                                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
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
                                            ],
                                          ),
                                        ),

                                      // Add comment input and post button
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: 'Add a comment...',
                                                  hintStyle: const TextStyle(color: Colors.white54),
                                                  filled: true,
                                                  fillColor: const Color(0xFF2B2F34),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                ),
                                                style: const TextStyle(color: Colors.white),
                                                controller: _commentControllers[postId] ??= TextEditingController(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF01416A),
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
                                              child: const Text('Post', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      const Divider(color: Colors.white, thickness: 1),

                                      // Action buttons: Like, Comment, Share, Delete
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              final response = await ServiceManager.instance.posts.toggleLike(post['_id'].toString());
                                              if (response['success'] == true) {
                                                setState(() {
                                                  List<dynamic> likes = response['data']['likes'] ?? [];
                                                  post['likes'] = likes;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(response['message'] ?? 'Failed to like post'),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  (post['likes'] ?? []).any((like) => like['_id'] == _currentUserId) ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                                  size: 20,
                                                  color: (post['likes'] ?? []).any((like) => like['_id'] == _currentUserId) ? Colors.white : Colors.white70,
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
                                              children: const [
                                                Icon(Icons.mode_comment_outlined, size: 20, color: Colors.white70),
                                                SizedBox(height: 4),
                                                Text('Comment', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Share.share(post['content'] ?? post['text'] ?? '');
                                            },
                                            child: Column(
                                              children: const [
                                                Icon(Icons.share_outlined, size: 20, color: Colors.white70),
                                                SizedBox(height: 4),
                                                Text('Share', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          if ((post['author']?['_id'] == _currentUserId) || (_myProfile != null && post['author']?['_id'] == _myProfile?['user']?['_id']))
                                            GestureDetector(
                                              onTap: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: const Color(0xFF22252A),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    title: Text('Delete Post', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    content: Text('Are you sure you want to delete this post?', style: GoogleFonts.dmSans(color: Colors.white70)),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(false),
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.white70,
                                                        ),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(true),
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.redAccent,
                                                        ),
                                                        child: const Text('Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  final response = await ServiceManager.instance.posts.deletePost(post['_id'].toString());
                                                  if (response['success'] == true) {
                                                    setState(() {
                                                      _posts.removeAt(idx);
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Post deleted'),
                                                        backgroundColor: Color(0xFF2B2F34),
                                                        behavior: SnackBarBehavior.floating,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(response['message'] ?? 'Failed to delete post'),
                                                        backgroundColor: Colors.redAccent,
                                                        behavior: SnackBarBehavior.floating,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF2B2F34),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    padding: const EdgeInsets.all(6),
                                                    child: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('Delete', style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
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
                  ),
      ),
    );
  }
}