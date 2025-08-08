import 'package:flutter/material.dart';
import 'package:reva/peopleyoumayknow/people_connect_screen.dart';

class PeopleYouMayKnowCard extends StatelessWidget {
  final String name;
  final String image;
  final String userId;
  final String location;
  final String designation;
  const PeopleYouMayKnowCard({
    super.key,
    required this.name,
    required this.image,
    required this.userId,
    this.location = '',
    this.designation = '',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Center(
      child: SizedBox(
        width: width * 0.38,
        height: width * 0.56,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/peopleyoumayknowtile_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 16),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 1, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: width * 0.08,
                    backgroundImage: image.isNotEmpty && !image.contains('assets/') ? NetworkImage(image) : AssetImage('assets/dummyprofile.png') as ImageProvider,
                  ),
                ),
              ),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 0.5),
              Center(
                child: designation.isNotEmpty
                    ? Text(
                        designation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFB1B5BA),
                          fontSize: 11.5,
                          height: 1.1,
                        ),
                      )
                    : Text(
                        "not available",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFB1B5BA),
                          fontSize: 11.5,
                        ),
                      ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFFB1B5BA),
                      fontSize: 10.5,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PeopleConnectScreen(
                          userId: userId,
                          initialName: name,
                          initialImage: image,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01416A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 0,
                  ),
                  child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
