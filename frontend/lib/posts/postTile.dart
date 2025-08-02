import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostTile extends StatelessWidget {
  const PostTile({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3339),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kateryna Luibinskaya and Tatyana Romanova like this",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const Divider(color: Color(0xFFCED5DC),thickness: 2,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Stanislav Naida •",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Builder, New Delhi",
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          const Icon(Icons.public, size: 12, color: Colors.white60),
                          const SizedBox(width: 4),
                          const Text("16h", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Image.asset("assets/silverpostbadge.png",height: 60,)
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Hello, I am looking for a new career opportunity and would I’m currently working with a buyer looking for a 3BHK",
              style: TextStyle(color: Colors.white, fontSize: 13.5),
            ),
            const SizedBox(height: 4),
            TextButton(onPressed: (){},child: Text("read more", style: TextStyle(color: Colors.lightBlue, fontSize: 13.5))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("11 comments", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
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