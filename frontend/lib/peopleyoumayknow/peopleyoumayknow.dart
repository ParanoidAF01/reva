import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/contacts/contacts.dart';
import 'package:reva/peopleyoumayknow/peopleyoumayknowtile.dart';
import 'package:reva/request/requestscreen.dart';
import 'package:reva/services/service_manager.dart';

import '../notification/notification.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPeople();
    });
  }

  Future<void> _fetchPeople() async {
    final provider =
        Provider.of<PeopleYouMayKnowProvider>(context, listen: false);
    provider.setLoading(true);

    try {
      final response =
          await ServiceManager.instance.connections.getConnectionSuggestions();
      if (response['success'] == true) {
        final suggestions = response['data']['suggestions'] ?? [];
        // Map API fields to card fields
        final mapped = suggestions
            .map((person) => {
                  'name': person['fullName'] ?? 'Unknown',
                  'image': person['profile'] ?? 'assets/dummyprofile.png',
                  'mobileNumber': person['mobileNumber'] ?? '',
                  'userId': person['_id'] ?? '',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  const TriangleIcon(size: 20, color: Colors.white),
                  SizedBox(width: width * 0.05),
                  Text(
                    "People you may know",
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  Expanded(
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
                          const Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white54,
                              decoration: InputDecoration(
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
                  SizedBox(width: width * 0.03),
                  // Filter Button
                  InkWell(
                    onTap: () {
                      // TODO: Add filter action
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: width * 0.12,
                      width: width * 0.2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0262AB), Color(0xFF01345A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),

            // Find in Contacts Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement find in contacts action
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Contacts()),
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
                    'Find in Contacts',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement find in contacts action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RequestScreen()),
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
            ),

            // Grid View for Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Consumer<PeopleYouMayKnowProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0262AB),
                      ),
                    );
                  }

                  final people = provider.people;
                  if (people.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.1),
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No suggestions found',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 8),
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
                      shrinkWrap: true,
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

            SizedBox(height: height * 0.05), // Bottom padding
          ],
        ),
      ),
    );
  }
}
