import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int expandedFaq = 0;
  final List<Map<String, String>> faqs = [
    {
      'q': 'How do I manage my account?',
      'a': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.'
    },
    {
      'q': 'How do I manage my notifications?',
      'a': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
    },
    {
      'q': 'How do I manage my notifications?',
      'a': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
    },
    {
      'q': 'How do I manage my notifications?',
      'a': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
    },
    {
      'q': 'How do I manage my notifications?',
      'a': 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23262B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23262B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Help Center', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact Us'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // FAQ Tab
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF23262B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24.withOpacity(0.18)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.search, color: Colors.white54),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search for help',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: faqs.length,
                    itemBuilder: (context, i) {
                      final isExpanded = expandedFaq == i;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF23262B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24.withOpacity(0.18)),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(faqs[i]['q']!, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
                              trailing: Icon(isExpanded ? Icons.remove : Icons.add, color: Colors.white),
                              onTap: () {
                                setState(() {
                                  expandedFaq = isExpanded ? -1 : i;
                                });
                              },
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(faqs[i]['a']!, style: GoogleFonts.dmSans(color: Colors.white70)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text('Reva', style: GoogleFonts.dmSans(color: Colors.white24, fontWeight: FontWeight.w700, fontSize: 22)),
                ),
              ],
            ),
          ),
          // Contact Us Tab
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _contactTile(context, Icons.headset, 'Customer Services', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerServiceChatScreen()));
                      }),
                      _contactTile(context, Icons.message, 'WhatsApp'),
                      _contactTile(context, Icons.language, 'Website'),
                      _contactTile(context, Icons.facebook, 'Facebook'),
                      _contactTile(context, Icons.alternate_email, 'Twitter'),
                      _contactTile(context, Icons.camera_alt, 'Instagram'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text('Reva', style: GoogleFonts.dmSans(color: Colors.white24, fontWeight: FontWeight.w700, fontSize: 22)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24.withOpacity(0.18)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
        onTap: onTap,
      ),
    );
  }
}

class CustomerServiceChatScreen extends StatelessWidget {
  const CustomerServiceChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23262B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23262B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Customer Sevice', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Today', style: GoogleFonts.dmSans(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                _chatBubble('Lorem Ipsum is simply dummy text of the printing.', isMe: false),
                _chatBubble('Lorem Ipsum is simply dummy text of the printing.', isMe: true),
                _chatBubble('Lorem Ipsum is simply dummy text of the printing.', isMe: false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Color(0xFF01416A),
                  child: Icon(Icons.mic, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueGrey[800] : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: GoogleFonts.dmSans(color: Colors.white)),
      ),
    );
  }
}
