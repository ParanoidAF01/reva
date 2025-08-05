import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/contacts/contacttile.dart';
import 'package:reva/services/service_manager.dart';
import 'package:provider/provider.dart';

import '../notification/notification.dart';

// Provider for contacts data
class ContactsProvider extends ChangeNotifier {
  List<dynamic> _contacts = [];
  bool _isLoading = false;

  List<dynamic> get contacts => _contacts;
  bool get isLoading => _isLoading;

  void setContacts(List<dynamic> contacts) {
    _contacts = contacts;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => ContactsProvider(),
      child: _ContactsBody(height: height, width: width),
    );
  }
}

class _ContactsBody extends StatefulWidget {
  final double height;
  final double width;
  const _ContactsBody({required this.height, required this.width});

  @override
  State<_ContactsBody> createState() => _ContactsBodyState();
}

class _ContactsBodyState extends State<_ContactsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchContacts();
    });
  }

  Future<void> _fetchContacts() async {
    final provider = Provider.of<ContactsProvider>(context, listen: false);
    provider.setLoading(true);

    try {
      final response =
          await ServiceManager.instance.connections.getMyConnections();
      if (response['success'] == true) {
        final contacts = response['data']['connections'] ?? [];
        provider.setContacts(contacts);
      } else {
        provider.setContacts([]);
      }
    } catch (e) {
      print('Error fetching contacts: $e');
      provider.setContacts([]);
    } finally {
      provider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = widget.height;
    var width = widget.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  const TriangleIcon(
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: width * 0.25,
                  ),
                  Text(
                    "Contacts",
                    style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
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
                          const Icon(Icons.search,
                              color: Colors.white70, size: 22),
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
                  )
                ],
              ),
            ),
            SizedBox(
              height: height * 0.03,
            ),

            // Contacts List
            Consumer<ContactsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0262AB),
                    ),
                  );
                }

                if (provider.contacts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Center(
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
                            'No contacts found',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You don\'t have any connections yet',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: provider.contacts.map((contact) {
                    return ContactTile(
                      name: contact['fullName'] ?? 'Unknown',
                      image: contact['profile'] ?? 'assets/dummyprofile.png',
                      mobileNumber: contact['mobileNumber'] ?? '',
                      userId: contact['_id'] ?? '',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
