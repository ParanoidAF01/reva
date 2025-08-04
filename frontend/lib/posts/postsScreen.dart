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
      final matchesSearch = _searchText.isEmpty ||
          (post['name'] as String)
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          (post['role'] as String)
              .toLowerCase()
              .contains(_searchText.toLowerCase()) ||
          (post['text'] ?? '')
              .toLowerCase()
              .contains(_searchText.toLowerCase());
      final matchesBadge =
          _selectedBadge == null || post['badge'] == _selectedBadge;
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
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
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
                                      const Icon(Icons.search,
                                          color: Colors.white54, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          cursorColor: Colors.white54,
                                          decoration: const InputDecoration(
                                            hintText: 'Search...',
                                            hintStyle:
                                                TextStyle(color: Colors.white54),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: const Text(
                                    'Search',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Simple filter dropdown
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: const Color(0xFF2B2F34),
                                  value: _selectedBadge,
                                  hint: const Text('Filter',
                                      style: TextStyle(color: Colors.white54)),
                                  icon: const Icon(Icons.filter_list,
                                      color: Colors.white),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All',
                                          style: GoogleFonts.dmSans(
                                              color: Colors.white)),
                                    ),
                                    DropdownMenuItem(
                                      value: 'silver',
                                      child: Row(children: [
                                        Image.asset('assets/silverpostbadge.png',
                                            height: 16),
                                        const SizedBox(width: 6),
                                        Text('Silver',
                                            style: GoogleFonts.dmSans(
                                                color: Colors.white))
                                      ]),
                                    ),
                                    DropdownMenuItem(
                                      value: 'bronze',
                                      child: Row(children: [
                                        Image.asset('assets/bronzepostbadge.png',
                                            height: 16),
                                        const SizedBox(width: 6),
                                        Text('Bronze',
                                            style: GoogleFonts.dmSans(
                                                color: Colors.white))
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
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.012),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23262B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundImage:
                                            post['profile'] != null &&
                                                    post['profile']
                                                        .toString()
                                                        .startsWith('http')
                                                ? NetworkImage(post['profile'])
                                                : AssetImage(post['profile'] ??
                                                        'assets/dummyprofile.png')
                                                    as ImageProvider,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(post['name'] ?? '',
                                                    style: GoogleFonts.dmSans(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                        fontSize: 16)),
                                                const SizedBox(width: 6),
                                                if (post['badgeAsset'] != null)
                                                  (post['badgeAsset']
                                                          .toString()
                                                          .startsWith('http'))
                                                      ? Image.network(
                                                          post['badgeAsset'],
                                                          height: 18)
                                                      : Image.asset(
                                                          post['badgeAsset'],
                                                          height: 18),
                                              ],
                                            ),
                                            Text(post['role'] ?? '',
                                                style: GoogleFonts.dmSans(
                                                    color: Colors.white70,
                                                    fontSize: 13)),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(post['time'] ?? '',
                                                    style: GoogleFonts.dmSans(
                                                        color: Colors.white54,
                                                        fontSize: 12)),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.public,
                                                    color: Colors.white54,
                                                    size: 13),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.more_horiz,
                                          color: Colors.white54),
                                    ],
                                  ),
                                  if (post['text'] != null) ...[
                                    const SizedBox(height: 10),
                                    Text(post['text'],
                                        style: GoogleFonts.dmSans(
                                            color: Colors.white, fontSize: 15)),
                                  ],
                                  if (post['image'] != null) ...[
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: post['image']
                                              .toString()
                                              .startsWith('http')
                                          ? Image.network(post['image'],
                                              height: 140,
                                              width: double.infinity,
                                              fit: BoxFit.cover)
                                          : Image.asset(post['image'],
                                              height: 140,
                                              width: double.infinity,
                                              fit: BoxFit.cover),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Text('${post['comments'] ?? 0} comments',
                                      style: GoogleFonts.dmSans(
                                          color: Colors.white54, fontSize: 13)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (idx < _likedPosts.length) {
                                              _likedPosts[idx] =
                                                  !_likedPosts[idx];
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Icon(
                                              (idx < _likedPosts.length &&
                                                      _likedPosts[idx])
                                                  ? Icons.thumb_up_alt
                                                  : Icons.thumb_up_alt_outlined,
                                              color: (idx < _likedPosts.length &&
                                                      _likedPosts[idx])
                                                  ? Colors.white
                                                  : Colors.white70,
                                            ),
                                            const SizedBox(height: 2),
                                            Text('Like',
                                                style: GoogleFonts.dmSans(
                                                    color: Colors.white70,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(
                                            Icons.mode_comment_outlined,
                                            'Comment'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(
                                            Icons.share_outlined, 'Share'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: _postAction(
                                            Icons.send_outlined, 'Send'),
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

  Widget _postAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
