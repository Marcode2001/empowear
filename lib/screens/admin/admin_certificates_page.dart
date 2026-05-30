// lib/screens/admin/admin_certificates_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empower/screens/trainee/certificate_viewer_page.dart';

import '../../bloc/certificate/certificate_bloc.dart';
import '../../bloc/certificate/certificate_event.dart';
import '../../bloc/certificate/certificate_state.dart';

class AdminCertificatesPage extends StatefulWidget {
  const AdminCertificatesPage({super.key});

  @override
  State<AdminCertificatesPage> createState() =>
      _AdminCertificatesPageState();
}

class _AdminCertificatesPageState
    extends State<AdminCertificatesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CertificateBloc>()
        .add(LoadAllCertificatesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Certificates',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ===================================================
          // Search Field - خلفية بيضاء عشان تتبين
          // ===================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white54, // ✅ خلفية بيضاء
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search trainee...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    onPressed: () => setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    }),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),
          ),
          // Results counter
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_getFilteredCertificates(context).length} results found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 4),
          // ===================================================
          // Certificates List
          // ===================================================
          Expanded(
            child: BlocBuilder<CertificateBloc, CertificateState>(
              builder: (context, state) {
                if (state is CertificateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  );
                }
                if (state is CertificateLoaded) {
                  final certificates = _getFilteredCertificates(context);

                  if (certificates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_searchQuery.isNotEmpty) ...[
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No certificates found for "$_searchQuery"',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ] else ...[
                            const Icon(Icons.workspace_premium, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No certificates found',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      final certificate = certificates[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          certificate.traineeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          certificate.courseTitle,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Code: ${certificate.certificateCode}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Level: ${certificate.levelNumber}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Issued By: ${certificate.issuedBy}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purple],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CertificateViewerPage(
                                          pdfUrl: certificate.fullCertificateUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text(
                                    'OPEN CERTIFICATE',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to filter certificates based on search query
  List<dynamic> _getFilteredCertificates(BuildContext context) {
    final state = context.read<CertificateBloc>().state;
    if (state is! CertificateLoaded) return [];

    final allCertificates = state.certificates;

    if (_searchQuery.isEmpty) return allCertificates;

    return allCertificates.where((certificate) {
      return certificate.traineeName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }
}