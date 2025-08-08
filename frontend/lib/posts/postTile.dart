import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostTile extends StatelessWidget {
  const PostTile({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: const BoxDecoration(
          color: Color(0xFF2E3339),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                // Example dynamic list, replace with actual data source
                final List<String> likedUsers = [
                  "Kateryna Luibinskaya",
                  "Tatyana Romanova"
                  // Add more usernames as needed
                ];
                // Truncate names to 14 characters max, append ...
                final truncatedNames = likedUsers.map((name) =>
                    name.length > 14 ? name.substring(0, 14) + '...' : name
                ).toList();

                String likeText;
                if (truncatedNames.isEmpty) {
                  likeText = '';
                } else if (truncatedNames.length == 1) {
                  likeText = '${truncatedNames[0]} likes this';
                } else if (truncatedNames.length == 2) {
                  likeText = '${truncatedNames[0]} and ${truncatedNames[1]} like this';
                } else {
                  likeText = truncatedNames.sublist(0, truncatedNames.length - 1).join(', ') +
                      ' and ${truncatedNames.last} like this';
                }
                return Text(
                  likeText,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            const Divider(color: Color(0xFFCED5DC), thickness: 2,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                SizedBox(width: size.width * 0.03),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stanislav Naida •",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Text(
                            "Builder, New Delhi",
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.public, size: 12, color: Colors.white60),
                          SizedBox(width: 4),
                          Text("16h", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Image.asset("assets/silverpostbadge.png", height: 60,)
              ],
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                final String content = "Hello, I am looking for a new career opportunity and would I’m currently working with a buyer looking for a 3BHK";
                bool isExpanded = false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      maxLines: isExpanded ? null : 5,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? "show less" : "read more",
                        style: const TextStyle(color: Colors.lightBlue, fontSize: 13.5),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("11 comments", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8,),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PostActionButton(icon: LucideIcons.thumbsUp, label: 'Like'),
                PostActionButton(icon: LucideIcons.messageCircle, label: 'Comment'),
                PostActionButton(icon: LucideIcons.share2, label: 'Share'),
                PostActionButton(icon: LucideIcons.send, label: 'Send'),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const PostActionButton({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))
      ],
    );
  }
}
