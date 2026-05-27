// lib/screen/admin/admin_applications_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState
    extends State<AdminApplicationsScreen> {

  List applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  // =========================================================
  // 📥 تحميل الطلبات
  // =========================================================

  Future<void> _loadApplications() async {

    setState(() => isLoading = true);

    try {

      final response = await ApiService.get(
        endpoint: 'application/',
        requireAuth: true,
      );

      print("📦 Applications Response:");
      print(response);

      if (response['success'] == true) {

        applications = response['data'] ?? [];
      }

    } catch (e) {

      print("❌ Load Applications Error: $e");
    }

    if (mounted) {

      setState(() => isLoading = false);
    }
  }

  // =========================================================
  // ✅ تحديث حالة الطلب
  // =========================================================

  Future<void> _updateStatus(
      String applicationId,
      String status,
      ) async {

    try {

      String endpoint = '';

      if (status == 'approved') {

        endpoint =
        'application/$applicationId/accept/';

      } else {

        endpoint =
        'application/$applicationId/reject/';
      }

      final response = await ApiService.put(
        endpoint: endpoint,
        data: {},
        requireAuth: true,
      );

      print("📦 Update Status Response:");
      print(response);

      if (response['success'] == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Application Approved'
                  : 'Application Rejected',
            ),
            backgroundColor:
            status == 'approved'
                ? Colors.green
                : Colors.red,
          ),
        );

        _loadApplications();
      }

    } catch (e) {

      print("❌ Update Status Error: $e");
    }
  }

  // =========================================================
  // 🎨 لون الحالة
  // =========================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {

      case 'accepted':
      case 'approved':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =========================================================
  // 🔥 أيقونة الحالة
  // =========================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {

      case 'accepted':
      case 'approved':
        return Icons.check_circle;

      case 'pending':
        return Icons.hourglass_bottom;

      case 'rejected':
        return Icons.cancel;

      default:
        return Icons.help;
    }
  }

  // =========================================================
  // 📅 تنسيق التاريخ
  // =========================================================

  String _formatDate(String? rawDate) {

    if (rawDate == null) return 'Unknown';

    try {

      final date = DateTime.parse(rawDate);

      return '${date.day}/${date.month}/${date.year}';

    } catch (_) {

      return 'Unknown';
    }
  }

  // =========================================================
  // 🖥️ الواجهة
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(

        title: const Text(
          'Applications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple,
              ],
            ),
          ),
        ),
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : applications.isEmpty

          ? const Center(
        child: Text(
          'No Applications Yet',
        ),
      )

          : RefreshIndicator(

        onRefresh: _loadApplications,

        child: ListView.builder(

          padding: const EdgeInsets.all(16),

          itemCount: applications.length,

          itemBuilder: (context, index) {

            final app = applications[index];

            // ✅ API الحالي يرجع application_status
            final status =
            (app['application_status'] ?? 'pending').toString().toLowerCase();

            // ✅ اسم مؤقت لأن الباك لا يرجع user_name
            final traineeName =
                app['trainee_name'] ?? 'Unknown Trainee';

            final jobTitle =
                app['job_title'] ?? 'Unknown Job';

            return Container(

              margin: const EdgeInsets.only(
                bottom: 16,
              ),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(
                    color: Colors.grey.withOpacity(
                      0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // =====================================================
                  // 👤 معلومات الطالب
                  // =====================================================

                  Row(

                    children: [

                      CircleAvatar(

                        backgroundColor:
                        Colors.deepPurple
                            .withOpacity(0.1),

                        child: Text(

                          traineeName[0].toUpperCase(),

                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              traineeName,

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(

                              'Applied: ${_formatDate(app['applied_at'])}',

                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =====================================================
                      // 📌 حالة الطلب
                      // =====================================================

                      Container(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(

                          color: _statusColor(
                            status,
                          ).withOpacity(0.1),

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Row(

                          mainAxisSize:
                          MainAxisSize.min,

                          children: [

                            Icon(

                              _statusIcon(status),

                              size: 14,

                              color: _statusColor(
                                status,
                              ),
                            ),

                            const SizedBox(width: 4),

                            Text(

                              status.toUpperCase(),

                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                _statusColor(
                                  status,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =====================================================
                  // 💼 معلومات الوظيفة
                  // =====================================================

                  Container(

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(

                      color: Colors.grey.shade50,

                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: Row(

                      children: [

                        const Icon(
                          Icons.work,
                          color: Colors.teal,
                        ),

                        const SizedBox(width: 10),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                jobTitle,

                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =====================================================
                  // ✅ أزرار الموافقة والرفض
                  // =====================================================

                  if (status == 'pending')

                    Row(

                      children: [

                        Expanded(

                          child: ElevatedButton.icon(

                            onPressed: () {

                              _updateStatus(
                                app['id'].toString(),
                                'approved',
                              );
                            },

                            icon: const Icon(
                              Icons.check,
                            ),

                            label: const Text(
                              'Approve',
                            ),

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.green,

                              foregroundColor:
                              Colors.white,

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                vertical: 14,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: ElevatedButton.icon(

                            onPressed: () {

                              _updateStatus(
                                app['id'].toString(),
                                'rejected',
                              );
                            },

                            icon: const Icon(
                              Icons.close,
                            ),

                            label: const Text(
                              'Reject',
                            ),

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.red,

                              foregroundColor:
                              Colors.white,

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                vertical: 14,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}