import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/request/requesttile.dart';
import 'package:reva/services/service_manager.dart';
import 'package:provider/provider.dart';


// Provider for pending requests data
class PendingRequestsProvider extends ChangeNotifier {
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

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => PendingRequestsProvider(),
      child: _RequestScreenBody(height: height, width: width),
    );
  }
}

class _RequestScreenBody extends StatefulWidget {
  final double height;
  final double width;
  const _RequestScreenBody({required this.height, required this.width});

  @override
  State<_RequestScreenBody> createState() => _RequestScreenBodyState();
}

class _RequestScreenBodyState extends State<_RequestScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPendingRequests();
    });
  }

  Future<void> _fetchPendingRequests() async {
    final provider = Provider.of<PendingRequestsProvider>(context, listen: false);
    provider.setLoading(true);

    try {
      final response = await ServiceManager.instance.connections.getPendingRequests();
      print('PENDING REQUESTS RESPONSE:');
      print('Response: $response');

      if (response['success'] == true) {
        final requests = response['data']['pendingRequests'] ?? [];
        print('Requests data: $requests');

        // Log each request to see the structure
        for (int i = 0; i < requests.length; i++) {
          print('Request $i: ${requests[i]}');
          print('Request $i fullName: ${requests[i]['fullName']}');
          print('Request $i fromUser: ${requests[i]['fromUser']}');
        }

        provider.setRequests(requests);
      } else {
        provider.setRequests([]);
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
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
          "Requests",
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
            SizedBox(
              height: height * 0.03,
            ),

            // Requests List
            Consumer<PendingRequestsProvider>(
              builder: (context, provider, child) {
                return RefreshIndicator(
                  onRefresh: _fetchPendingRequests,
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
                                    Icons.person_add_disabled,
                                    size: 64,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No pending requests',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'You don\'t have any pending connection requests',
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
                            children: provider.requests.map((request) {
                              return RequestTile(
                                name: request['fullName'] ?? 'Unknown',
                                image: request['profile'] ?? 'assets/dummyprofile.png',
                                mobileNumber: request['mobileNumber'] ?? '',
                                requestId: request['_id'] ?? '',
                                onRefresh: _fetchPendingRequests,
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
