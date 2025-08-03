import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva/events/eventtile.dart';
import 'package:reva/events/event_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:reva/posts/postTile.dart';

// import '../notification/notification.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<EventModel> events = [];
  List<EventModel> filteredEvents = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String selectedCity = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse('https://example.com/api/events'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        events = data.map((e) => EventModel.fromJson(e)).toList();
        filteredEvents = List.from(events);
      } else {
        error = 'Failed to load events';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  void filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        final matchesSearch = event.title.toLowerCase().contains(searchQuery.toLowerCase()) || event.location.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCity = selectedCity.isEmpty || event.location.toLowerCase() == selectedCity.toLowerCase();
        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF22252A),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    SizedBox(height: height * 0.06),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23262B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Events",
                            style: GoogleFonts.dmSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
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
                                  const Icon(Icons.search, color: Colors.white70, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      style: const TextStyle(color: Colors.white),
                                      cursorColor: Colors.white54,
                                      decoration: const InputDecoration(
                                        hintText: 'Search By City Or Name...',
                                        hintStyle: TextStyle(color: Colors.white54),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (val) {
                                        searchQuery = val;
                                        filterEvents();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.filter_alt_rounded, color: Color(0xFF3B9FED), size: 28),
                                    onPressed: () async {
                                      // Simple city filter dialog
                                      final cities = events.map((e) => e.location).toSet().toList();
                                      final selected = await showDialog<String>(
                                        context: context,
                                        builder: (context) => SimpleDialog(
                                          title: const Text('Filter by City'),
                                          children: [
                                            SimpleDialogOption(
                                              onPressed: () => Navigator.pop(context, ''),
                                              child: const Text('All'),
                                            ),
                                            ...cities.map((city) => SimpleDialogOption(
                                                  onPressed: () => Navigator.pop(context, city),
                                                  child: Text(city),
                                                )),
                                          ],
                                        ),
                                      );
                                      if (selected != null) {
                                        selectedCity = selected;
                                        filterEvents();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: EventTile(event: filteredEvents[index]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
