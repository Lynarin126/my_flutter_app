import 'package:flutter/material.dart';
import '../Page/NotificationPage.dart'; // ✅ Import

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String userName;
  final int notificationCount; // ✅ Badge Count

  const CustomAppBar({
    super.key,
    required this.userName,
    this.notificationCount = 0, // ✅ Default = 0
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF27AE60), // ✅ ពណ៌បៃតងដូច App
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Profile Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5),
            ),
            child: const Icon(Icons.person,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          // Greeting + Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "សួស្តី 👋",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70),
              ),
              Text(
                userName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ============================
        // ✅ Notification Bell + Badge
        // ============================
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const NotificationPage(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.all(6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bell Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                // ✅ Badge
                if (notificationCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 99
                            ? "99+"
                            : "$notificationCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // More Options
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_vert,
                color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}