import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/contacts/contacttile.dart';
import 'package:reva/services/service_manager.dart';
import 'package:provider/provider.dart';

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
  String? selectedDesignation;
  String? _searchQuery;

  List<String> getAvailableDesignations(List<dynamic> contacts) {
    final designations = <String>{};
    for (final c in contacts) {
      final d1 = c['designation']?.toString();
      if (d1 != null && d1.isNotEmpty) designations.add(d1);
      final d2 = c['profile'] is Map ? c['profile']['designation']?.toString() : null;
      if (d2 != null && d2.isNotEmpty) designations.add(d2);
    }
    final list = designations.toList();
    list.sort();
    return list;
  }

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
      final response = await ServiceManager.instance.connections.getMyConnections();
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF22252A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Contacts",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<ContactsProvider>(
        builder: (context, provider, child) {
          final allDesignations = getAvailableDesignations(provider.contacts);
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Row(
                    children: [
                      // Dynamic search bar
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
                              const Icon(Icons.search, color: Colors.white70, size: 22),
                              SizedBox(width: width * 0.02),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.white54,
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      // Filter Button
                      InkWell(
                        onTap: () async {
                          final result = await showModalBottomSheet<String>(
                            context: context,
                            backgroundColor: const Color(0xFF23262B),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text('Filter by Designation', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ),
                                  ...allDesignations.map((designation) => ListTile(
                                        title: Text(designation, style: GoogleFonts.dmSans(color: Colors.white)),
                                        tileColor: selectedDesignation == designation ? const Color(0xFF0262AB) : Colors.transparent,
                                        onTap: () => Navigator.pop(context, designation),
                                      )),
                                  ListTile(
                                    title: Text('Clear Filter', style: GoogleFonts.dmSans(color: Colors.redAccent)),
                                    onTap: () => Navigator.pop(context, null),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          );
                          setState(() {
                            selectedDesignation = result;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: width * 0.12,
                          width: width * 0.32,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.filter_list, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                selectedDesignation == null ? 'Filter' : selectedDesignation!,
                                style: const TextStyle(
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
                // Contacts List
                if (provider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0262AB),
                    ),
                  )
                else if (provider.contacts.isEmpty)
                  Padding(
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
                            'You don\'t have connections',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Connect with people to see them here.',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  RefreshIndicator(
                    onRefresh: _fetchContacts,
                    color: const Color(0xFF0262AB),
                    backgroundColor: const Color(0xFF22252A),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: provider.contacts.where((contact) {
                          final designation = contact['designation']?.toString() ?? contact['profile']?['designation']?.toString() ?? '';
                          final matchesDesignation = selectedDesignation == null || designation == selectedDesignation;
                          final matchesSearch = _searchQuery == null || _searchQuery!.isEmpty || (contact['fullName']?.toString().toLowerCase().contains(_searchQuery!.toLowerCase()) ?? false) || (contact['profile']?['fullName']?.toString().toLowerCase().contains(_searchQuery!.toLowerCase()) ?? false);
                          return matchesDesignation && matchesSearch;
                        }).map((contact) {
                          return ContactTile(
                            contact: contact,
                            onRemove: () async {
                              await ServiceManager.instance.connections.removeConnection(contact['_id']);
                              // Refresh contacts after removal
                              _fetchContacts();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
