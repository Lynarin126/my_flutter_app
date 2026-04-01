import 'package:flutter/material.dart';

// ============================
// Notification Model
// ============================
class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String detail;
  final String time;
  final String date;
  final String type; // payment_overdue, payment_due, payment_done, tenant_new, maintenance
  final String status; // unread, read
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
    required this.date,
    required this.type,
    required this.status,
    this.isRead = false,
  });
}

// ============================
// NotificationPage
// ============================
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  List<NotificationItem> notifications = [
    // ថ្ងៃនេះ
    NotificationItem(
      id: "1",
      title: "Room 004 មិនទាន់បង់ប្រាក់",
      subtitle: "ជួលប្រចាំខែ \$120 • ផុត 25 មេសា 2025",
      detail: "សាលែលេចឡើងកំណត់: ថ្ងៃនេះ",
      time: "2 នាទីមុន",
      date: "today",
      type: "payment_overdue",
      status: "unread",
      isRead: false,
    ),
    NotificationItem(
      id: "2",
      title: "Room 005 ក្រោយបង់ថ្ងៃស្អែក",
      subtitle: "ជួលប្រចាំខែ \$95 • ផុត 26 មេសា 2025",
      detail: "សល់ 1 ថ្ងៃទៀត",
      time: "1 ម៉ោងមុន",
      date: "today",
      type: "payment_due",
      status: "unread",
      isRead: false,
    ),
    NotificationItem(
      id: "3",
      title: "Room 002 បានបង់ប្រាក់រួចរាល់",
      subtitle: "Narin បានបង់ \$120 សម្រាប់ខែមេសា",
      detail: "បង់រួច • 24 មេសា 2025",
      time: "មិញនិច្ច",
      date: "today",
      type: "payment_done",
      status: "read",
      isRead: true,
    ),
    NotificationItem(
      id: "4",
      title: "Tenant ថ្មីចូលរួមបន្ទប់ Room 006",
      subtitle: "Reach ចូលរួមនៅថ្ងៃ 24 មេសា 2025",
      detail: "មើលព័ត៌មានអ្នករស់នៅថ្មី",
      time: "2 ថ្ងៃមុន",
      date: "today",
      type: "tenant_new",
      status: "read",
      isRead: true,
    ),
    // សប្តាហ៍មុន
    NotificationItem(
      id: "5",
      title: "Room 003 មានការជួសជុលបន្ទប់",
      subtitle: "ការជួសជុលម៉ាស៊ីនត្រជាក់ក្នុងបន្ទប់",
      detail: "រួចរាល់ • 23 មេសា 2025",
      time: "2 ថ្ងៃមុន",
      date: "week",
      type: "maintenance",
      status: "read",
      isRead: true,
    ),
    NotificationItem(
      id: "6",
      title: "Room 007 មិនទាន់បង់ប្រាក់",
      subtitle: "ជួលប្រចាំខែ \$110 • ផុត 20 មេសា 2025",
      detail: "ហួសសំណើ 4 ថ្ងៃ",
      time: "4 ថ្ងៃមុន",
      date: "week",
      type: "payment_overdue",
      status: "read",
      isRead: true,
    ),
  ];

  // ============================
  // Getters
  // ============================
  int get _unreadCount =>
      notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _todayNotifications =>
      notifications.where((n) => n.date == "today").toList();

  List<NotificationItem> get _weekNotifications =>
      notifications.where((n) => n.date == "week").toList();

  // ============================
  // Type Config
  // ============================
  Color _getBorderColor(String type) {
    switch (type) {
      case "payment_overdue": return Colors.red;
      case "payment_due":     return Colors.orange;
      case "payment_done":    return Colors.green;
      case "tenant_new":      return Colors.blue;
      case "maintenance":     return Colors.purple;
      default:                return Colors.grey;
    }
  }

  Color _getIconBg(String type) {
    switch (type) {
      case "payment_overdue": return Colors.red.shade50;
      case "payment_due":     return Colors.orange.shade50;
      case "payment_done":    return Colors.green.shade50;
      case "tenant_new":      return Colors.blue.shade50;
      case "maintenance":     return Colors.purple.shade50;
      default:                return Colors.grey.shade100;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case "payment_overdue": return Colors.red;
      case "payment_due":     return Colors.orange;
      case "payment_done":    return Colors.green;
      case "tenant_new":      return Colors.blue;
      case "maintenance":     return Colors.purple;
      default:                return Colors.grey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "payment_overdue": return Icons.receipt_long_outlined;
      case "payment_due":     return Icons.notifications_outlined;
      case "payment_done":    return Icons.check_circle_outline;
      case "tenant_new":      return Icons.person_add_outlined;
      case "maintenance":     return Icons.build_outlined;
      default:                return Icons.notifications_outlined;
    }
  }

  Color _getTagColor(String type) {
    switch (type) {
      case "payment_overdue": return Colors.red.shade50;
      case "payment_due":     return Colors.orange.shade50;
      case "payment_done":    return Colors.green.shade50;
      case "tenant_new":      return Colors.blue.shade50;
      case "maintenance":     return Colors.green.shade50;
      default:                return Colors.grey.shade100;
    }
  }

  Color _getTagTextColor(String type) {
    switch (type) {
      case "payment_overdue": return Colors.red;
      case "payment_due":     return Colors.orange;
      case "payment_done":    return Colors.green;
      case "tenant_new":      return Colors.blue;
      case "maintenance":     return Colors.green;
      default:                return Colors.grey;
    }
  }

  IconData _getTagIcon(String type) {
    switch (type) {
      case "payment_overdue": return Icons.access_time;
      case "payment_due":     return Icons.access_time;
      case "payment_done":    return Icons.check_circle;
      case "tenant_new":      return Icons.person;
      case "maintenance":     return Icons.check_circle;
      default:                return Icons.info;
    }
  }

  // ============================
  // Mark All Read
  // ============================
  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("បានអានការជូនដំណឹងទាំងអស់!"),
        backgroundColor: Color(0xFF27AE60),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ============================
  // Mark Single Read
  // ============================
  void _markAsRead(NotificationItem item) {
    setState(() => item.isRead = true);
  }

  // ============================
  // Delete Notification
  // ============================
  void _deleteNotification(NotificationItem item) {
    setState(() => notifications.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("បានលុបការជូនដំណឹង!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text("ការជូនដំណឹង",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [

          // ============================
          // ✅ Header Card
          // ============================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications,
                      color: Colors.blue.shade400,
                      size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight:
                              FontWeight.w500),
                          children: [
                            const TextSpan(
                                text: "អ្នកមានការជូនដំណឹង "),
                            TextSpan(
                              text: "$_unreadCount",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                            const TextSpan(
                                text: " មិនទាន់អាន"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "ប:លើការជូនដំណឹងដើម្បីមើលព័ត៌មានលម្អិត",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                // Mark all read button
                if (_unreadCount > 0)
                  OutlinedButton.icon(
                    onPressed: _markAllAsRead,
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6),
                      side: BorderSide(
                          color: Colors.blue.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.check,
                        size: 14,
                        color: Colors.blue.shade600),
                    label: Text(
                      "Mark all as read",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade600),
                    ),
                  ),
              ],
            ),
          ),

          // ============================
          // ✅ Today Section
          // ============================
          if (_todayNotifications.isNotEmpty) ...[
            _buildSectionHeader("ថ្ងៃនេះ"),
            ..._todayNotifications.map(
                    (n) => _buildNotificationCard(n)),
          ],

          // ============================
          // ✅ Week Section
          // ============================
          if (_weekNotifications.isNotEmpty) ...[
            _buildSectionHeader("សប្តាហ៍មុន"),
            ..._weekNotifications.map(
                    (n) => _buildNotificationCard(n)),
          ],

          // ============================
          // ✅ Info Bar
          // ============================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "ប:លើការជូនដំណឹងណាមួយ ដើម្បីរំកិលទៅកាន់មុខងារដំណើរការ",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ============================
      // ✅ FAB Filter
      // ============================
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }

  // ============================
  // Section Header
  // ============================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // ============================
  // ✅ Notification Card with Swipe
  // ============================
  Widget _buildNotificationCard(NotificationItem item) {
    return Dismissible(
      key: Key(item.id),

      // Swipe ស្តាំ → Mark as Read
      background: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_red_eye,
                color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text("Mark read",
                style: TextStyle(
                    color: Colors.white, fontSize: 11)),
          ],
        ),
      ),

      // Swipe ឆ្វេង → Delete
      secondaryBackground: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text("Delete",
                style: TextStyle(
                    color: Colors.white, fontSize: 11)),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          _markAsRead(item);
          return false; // មិនលុប
        } else {
          // Confirm Delete
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("លុបការជូនដំណឹង"),
              content:
              const Text("តើអ្នកចង់លុបការជូនដំណឹងនេះ?"),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text("បោះបង់"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text("លុប",
                      style:
                      TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ) ?? false;
        }
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteNotification(item);
        }
      },

      child: GestureDetector(
        onTap: () => _markAsRead(item),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          decoration: BoxDecoration(
            color: item.isRead
                ? Colors.white
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.grey.shade200),
            // ✅ Color Left Border
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ✅ Left Color Border
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _getBorderColor(item.type),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _getIconBg(item.type),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(item.type),
                            color: _getIconColor(item.type),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: item.isRead
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                        fontSize: 14,
                                        color: const Color(
                                            0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors
                                            .grey.shade400),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),

                              // ✅ Status Tag
                              Row(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal: 8,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getTagColor(
                                          item.type),
                                      borderRadius:
                                      BorderRadius
                                          .circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getTagIcon(
                                              item.type),
                                          size: 10,
                                          color:
                                          _getTagTextColor(
                                              item.type),
                                        ),
                                        const SizedBox(
                                            width: 4),
                                        Text(
                                          item.detail,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color:
                                            _getTagTextColor(
                                                item.type),
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  // Unread dot
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                      const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow
                        Icon(Icons.chevron_right,
                            color: Colors.grey.shade400,
                            size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // Empty State
  // ============================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 56, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text("គ្មានការជូនដំណឹង",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text("ការជូនដំណឹងថ្មីនឹងបង្ហាញនៅទីនេះ",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ============================
  // Filter Bottom Sheet
  // ============================
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("ត្រង់ការជូនដំណឹង",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Filter Options
            ...[
              {"label": "ទាំងអស់", "type": "all", "color": Colors.blue},
              {"label": "មិនទាន់បង់", "type": "payment_overdue", "color": Colors.red},
              {"label": "ជិតផុត", "type": "payment_due", "color": Colors.orange},
              {"label": "បានបង់", "type": "payment_done", "color": Colors.green},
              {"label": "Tenant ថ្មី", "type": "tenant_new", "color": Colors.blue},
              {"label": "ជួសជុល", "type": "maintenance", "color": Colors.purple},
            ].map((f) => ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: f["color"] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(f["label"] as String,
                  style: const TextStyle(fontSize: 14)),
              trailing: const Icon(
                  Icons.arrow_forward_ios, size: 14),
              onTap: () => Navigator.pop(context),
            )),
          ],
        ),
      ),
    );
  }
}