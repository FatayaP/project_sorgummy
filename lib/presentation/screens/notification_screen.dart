import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class NotificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialNotifications;
  
  const NotificationScreen({Key? key, required this.initialNotifications}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    // Menyalin data parameter awal ke dalam status lokal halaman
    _notifications = List<Map<String, dynamic>>.from(widget.initialNotifications);
  }

  // Fungsi mengklik notifikasi (Mengubah status baca ke false & menampilkan BottomSheet)
  void _onNotificationTap(int index) {
    setState(() {
      _notifications[index]['isUnread'] = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final notif = _notifications[index];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notif['title'],
                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      notif['time'],
                      style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  notif['desc'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.cardLightGrey),
                const SizedBox(height: 8),
                Text(
                  notif['detail'],
                  style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Menangani saat user menekan tombol back fisik HP bawaan Android
      onWillPop: () async {
        Navigator.pop(context, _notifications);
        return false;
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Scaffold(
          backgroundColor: AppColors.backgroundWhite,
          appBar: AppBar(
            title: const Text(
              'Notifikasi', 
              style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            // Perbaikan tombol back kustom agar melempar data status baca terbaru ke HomeScreen
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
              onPressed: () => Navigator.pop(context, _notifications),
            ),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: AppColors.cardLightGrey,
                height: 1.0,
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final bool isUnread = notif['isUnread'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isUnread ? const Color(0xFFF1F8E9) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isUnread ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.cardLightGrey,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onNotificationTap(index),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isUnread ? AppColors.primaryGreen : AppColors.textLight.withOpacity(0.1),
                                  child: Icon(
                                    notif['icon'], 
                                    color: isUnread ? Colors.white : AppColors.textLight, 
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif['title'],
                                              style: TextStyle(
                                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.textCharcoal,
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8, top: 4),
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryGreen,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notif['desc'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUnread ? AppColors.textCharcoal : AppColors.textLight,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notif['time'],
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}