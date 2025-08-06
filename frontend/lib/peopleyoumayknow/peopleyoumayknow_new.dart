import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/contacts/contacts.dart';
import 'package:reva/home/homescreen.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknowtile.dart';
import 'package:reva/request/requestscreen.dart';
import 'package:reva/services/service_manager.dart';
import 'package:provider/provider.dart';

// Provider for people you may know data
class PeopleYouMayKnowProvider extends ChangeNotifier {
  List<dynamic> _people = [];
  bool _isLoading = false;

  List<dynamic> get people => _people;
  bool get isLoading => _isLoading;

  void setPeople(List<dynamic> people) {
    _people = people;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class PeopleYouMayKnow extends StatelessWidget {
  const PeopleYouMayKnow({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => PeopleYouMayKnowProvider(),
      child: _PeopleYouMayKnowBody(height: height, width: width),
    );
  }
}

class _PeopleYouMayKnowBody extends StatefulWidget {
  final double height;
  final double width;
  const _PeopleYouMayKnowBody({required this.height, required this.width});

  @override
  State<_PeopleYouMayKnowBody> createState() => _PeopleYouMayKnowBodyState();
}

class _PeopleYouMayKnowBodyState extends State<_PeopleYouMayKnowBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPeople();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _fetchPeople() async {
    final provider = Provider.of<PeopleYouMayKnowProvider>(context, listen: false);
    provider.setLoading(true);

    try {
      final response = await ServiceManager.instance.connections.getConnectionSuggestions();
      if (response['success'] == true) {
        final suggestions = response['data']['suggestions'] ?? [];
        // Map API fields to card fields
        final mapped = suggestions
            .map((person) {
              String imageUrl = '';
              if (person['profile'] != null && person['profile'] is String && person['profile'].isNotEmpty) {
                imageUrl = person['profile'];
              }
              return {
                'name': person['fullName'] ?? 'Unknown',
                'image': imageUrl.isNotEmpty ? imageUrl : 'assets/dummyprofile.png',
                'mobileNumber': person['mobileNumber'] ?? '',
                'userId': person['_id'] ?? '',
                'location': person['location'] is String ? person['location'] : '',
              };
            })
            .toList();
        provider.setPeople(mapped);
      } else {
        provider.setPeople([]);
      }
    } catch (e) {
      print('Error fetching people suggestions: $e');
      provider.setPeople([]);
    } finally {
      provider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height;
    final width = widget.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          "People you may know",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.02),
            child: Container(
              height: width * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF2B2F34),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: width * 0.03),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.white70,
                    size: 22,
                  ),
                  SizedBox(width: width * 0.02),
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Contacts()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
                      backgroundColor: const Color(0xFF0262AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Find in Contacts',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RequestScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      backgroundColor: const Color(0xFF0262AB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View Requests',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid View for Cards
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
              child: Consumer<PeopleYouMayKnowProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0262AB),
                      ),
                    );
                  }

                  final people = provider.people.where((person) {
                    if (_searchQuery.isEmpty) return true;
                    final name = person['name']?.toLowerCase() ?? '';
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (people.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No suggestions found',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No people suggestions available at the moment',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _fetchPeople,
                    color: const Color(0xFF0262AB),
                    backgroundColor: const Color(0xFF22252A),
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: width * 0.03,
                        mainAxisSpacing: height * 0.02,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: people.length,
                      itemBuilder: (context, index) {
                        final person = people[index];
                        return PeopleYouMayKnowCard(
                          name: person['name'] ?? 'Unknown',
                          image: person['image'] ?? 'assets/dummyprofile.png',
                          userId: person['userId'] ?? '',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
