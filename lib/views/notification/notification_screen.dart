import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourguideapp/core/constants/app_colors.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/models/notification_model.dart';
import 'package:tourguideapp/core/services/notification_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:tourguideapp/core/services/used_services_service.dart';
import 'package:tourguideapp/views/service/used_service/used_service_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      print('Debug: Loading notifications for user: ${widget.userId}');
      final notifications = await _notificationService.getUserNotifications(widget.userId);
      final unreadCount = await _notificationService.getUnreadNotificationCount(widget.userId);
      
      print('Debug: Loaded ${notifications.length} notifications, $unreadCount unread');
      
      setState(() {
        _notifications = notifications;
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading notifications: $e');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
    await _loadNotifications(); // Reload để cập nhật UI
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllNotificationsAsRead(widget.userId);
    await _loadNotifications(); // Reload để cập nhật UI
  }

  Future<void> _deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
    await _loadNotifications(); // Reload để cập nhật UI
  }

  Future<void> _deleteAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('Xác nhận')),
        content: Text(AppLocalizations.of(context).translate('Bạn có chắc muốn xóa tất cả thông báo?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).translate('Hủy')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).translate('Xóa'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.deleteAllUserNotifications(widget.userId);
      await _loadNotifications(); // Reload để cập nhật UI
    }
  }

  String _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'hotel':
        return 'hotel';
      case 'restaurant':
        return 'restaurant';
      case 'delivery':
        return 'local_shipping';
      case 'bus':
        return 'directions_bus';
      case 'car_rental':
        return 'directions_car';
      case 'motorbike_rental':
        return 'two_wheeler';
      default:
        return 'notifications';
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'delivery':
        return Colors.green;
      case 'bus':
        return Colors.purple;
      case 'car_rental':
        return Colors.red;
      case 'motorbike_rental':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: 32.sp, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppLocalizations.of(context).translate('Thông báo'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: badges.Badge(
                showBadge: _unreadCount > 0,
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: const EdgeInsets.all(3),
                  borderRadius: BorderRadius.circular(10),
                  elevation: 0,
                ),
                badgeContent: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  alignment: Alignment.center,
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                position: badges.BadgePosition.topEnd(top: -2, end: -2),
                child: const Icon(Icons.notifications, color: Colors.white, size: 28),
              ),
            ),
            if (_unreadCount > 0)
              IconButton(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all),
                tooltip: AppLocalizations.of(context).translate('Đánh dấu tất cả đã đọc'),
              ),
            if (_notifications.isNotEmpty)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'delete_all':
                      _deleteAllNotifications();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context).translate('Xóa tất cả'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildShimmerList()
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: 180.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/empty_notification.png',
            width: 120.w,
            height: 120.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          Text(
            AppLocalizations.of(context).translate('Không có thông báo'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            AppLocalizations.of(context).translate('Bạn sẽ nhận được thông báo khi có dịch vụ mới'),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        alignment: Alignment.centerRight,
        height: null,
        padding: EdgeInsets.only(right: 40.w),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 36),
            SizedBox(width: 14.w),
            Text(
              AppLocalizations.of(context).translate('Xóa'),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20.sp, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (!notification.isRead) {
                await _markAsRead(notification.id);
              }
              // Nếu notification có serviceType và serviceId thì chuyển sang chi tiết dịch vụ
              if (notification.serviceType.isNotEmpty && notification.serviceId.isNotEmpty) {
                final usedService = await UsedServicesService().getUsedServiceByTypeAndId(
                  notification.userId,
                  notification.serviceType,
                  notification.serviceId,
                );
                if (usedService != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsedServiceDetailScreen(service: usedService),
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không tìm thấy thông tin dịch vụ!')),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: _getServiceColor(notification.serviceType).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Center(
                      child: Icon(
                        _getMaterialIcon(_getServiceIcon(notification.serviceType)),
                        color: _getServiceColor(notification.serviceType),
                        size: 26.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.w700,
                                  color: notification.isRead 
                                      ? Colors.black87 
                                      : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: badges.Badge(
                                  badgeContent: const SizedBox.shrink(),
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.blue,
                                    shape: badges.BadgeShape.circle,
                                    padding: EdgeInsets.all(5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 13.sp,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getServiceColor(notification.serviceType).withOpacity(0.13),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                notification.serviceName,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _getServiceColor(notification.serviceType),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String iconName) {
    switch (iconName) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'directions_car':
        return Icons.directions_car;
      case 'two_wheeler':
        return Icons.two_wheeler;
      default:
        return Icons.notifications;
    }
  }
} 