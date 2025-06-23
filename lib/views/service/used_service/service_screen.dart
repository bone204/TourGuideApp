import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourguideapp/localization/app_localizations.dart';
import 'package:tourguideapp/widgets/used_service_card.dart';
import '../../../viewmodels/used_services_viewmodel.dart';
import 'used_service_detail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi fetch dữ liệu, userId sẽ được lấy trong ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsedServicesViewModel>().fetchUsedServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsedServicesViewModel>(
      builder: (context, vm, child) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Text(
                  AppLocalizations.of(context).translate('My Services'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.usedServices.isEmpty
                        ? const Center(child: Text('Không có dịch vụ nào đã sử dụng hoặc bạn chưa đăng nhập.'))
                        : ListView.builder(
                            itemCount: vm.usedServices.length,
                            itemBuilder: (context, index) {
                              final service = vm.usedServices[index];
                              return UsedServiceCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UsedServiceDetailScreen(service: service),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
