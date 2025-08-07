import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/request/requesttile.dart';
import 'package:reva/services/service_manager.dart';
import 'package:provider/provider.dart';

// Provider for outgoing requests data
class OutgoingRequestsProvider extends ChangeNotifier {
  List<dynamic> _requests = [];
  bool _isLoading = false;

  List<dynamic> get requests => _requests;
  bool get isLoading => _isLoading;

  void setRequests(List<dynamic> requests) {
    _requests = requests;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class OutgoingScreen extends StatelessWidget {
  const OutgoingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => OutgoingRequestsProvider(),
      child: _OutgoingScreenBody(height: height, width: width),
    );
  }
}

class _OutgoingScreenBody extends StatefulWidget {
  final double height;
  final double width;
  const _OutgoingScreenBody({required this.height, required this.width});

  @override
  State<_OutgoingScreenBody> createState() => _OutgoingScreenBodyState();
}

class _OutgoingScreenBodyState extends State<_OutgoingScreenBody> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOutgoingRequests();
    });
  }

  Future<void> _fetchOutgoingRequests() async {
    final provider = Provider.of<OutgoingRequestsProvider>(context, listen: false);
    provider.setLoading(true);
    try {
      final response = await ServiceManager.instance.connections.getSentRequests();
      if (response['success'] == true) {
        final requests = response['data']['sentRequests'] ?? [];
        provider.setRequests(requests);
      } else {
        provider.setRequests([]);
      }
    } catch (e) {
      provider.setRequests([]);
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
          "Outgoing Requests",
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: width * 0.12,
                      width: width * 0.2,
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
            SizedBox(height: height * 0.03),
            Consumer<OutgoingRequestsProvider>(
              builder: (context, provider, child) {
                final filteredRequests = provider.requests.where((request) {
                  final name = (request['fullName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();
                return RefreshIndicator(
                  onRefresh: _fetchOutgoingRequests,
                  color: const Color(0xFF0262AB),
                  backgroundColor: const Color(0xFF22252A),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (provider.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0262AB),
                            ),
                          )
                        else if (provider.requests.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: height * 0.1),
                                  Icon(
                                    Icons.send_and_archive,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No requests sent',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'You haven\'t sent any connection requests',
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
                        else if (filteredRequests.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: height * 0.1),
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No results found',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No outgoing requests match your search',
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
                          Column(
                            children: filteredRequests.map((request) {
                              // For outgoing, user data is in toUser
                              final user = request['toUser'] ?? {};
                              return RequestTile(
                                userData: user,
                                requestId: request['_id'] ?? '',
                                onRefresh: _fetchOutgoingRequests,
                                isOutgoing: true,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
