//lib/screens/admin/admin_certificates_page.dart


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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

final TextEditingController _searchController =
TextEditingController();

@override
void initState() {
super.initState();

context.read<CertificateBloc>()
    .add(LoadAllCertificatesEvent());
}

Future<void> _openCertificate(String url) async {

if (url.isEmpty) return;

final uri = Uri.parse(url);

if (await canLaunchUrl(uri)) {

await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);
}
}

@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor: Colors.grey.shade100,

appBar: AppBar(
elevation: 0,
centerTitle: true,
backgroundColor: Colors.deepPurple,

title: const Text(
'Certificates',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),

body: Column(
children: [

// ===================================================
// Search
// ===================================================

Container(
padding: const EdgeInsets.all(16),
color: Colors.white,

child: Row(
children: [

Expanded(
child: TextField(
controller: _searchController,

decoration: InputDecoration(

hintText: 'Search trainee...',

prefixIcon: const Icon(
Icons.search,
color: Colors.deepPurple,
),

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
),
),
),
),

const SizedBox(width: 12),

ElevatedButton(

onPressed: () {

context.read<CertificateBloc>().add(
SearchCertificatesEvent(
_searchController.text,
),
);
},

style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
foregroundColor: Colors.white,
),

child: const Text('Search'),
),
],
),
),

// ===================================================
// List
// ===================================================

Expanded(
child: BlocBuilder<
CertificateBloc,
CertificateState>(

builder: (context, state) {

if (state is CertificateLoading) {

return const Center(
child: CircularProgressIndicator(
color: Colors.deepPurple,
),
);
}

if (state is CertificateLoaded) {

final certificates = state.certificates;

if (certificates.isEmpty) {

return const Center(
child: Text(
'No certificates found',
),
);
}

return ListView.builder(

padding: const EdgeInsets.all(16),

itemCount: certificates.length,

itemBuilder: (context, index) {

final certificate =
certificates[index];

return Container(

margin:
const EdgeInsets.only(bottom: 16),

decoration: BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius.circular(22),

boxShadow: [
BoxShadow(
color:
Colors.deepPurple.withOpacity(0.08),

blurRadius: 10,
offset: const Offset(0, 5),
),
],
),

child: Padding(
padding: const EdgeInsets.all(18),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Row(
children: [

Container(
padding:
const EdgeInsets.all(10),

decoration: BoxDecoration(
color: Colors.deepPurple
    .withOpacity(0.1),

borderRadius:
BorderRadius.circular(12),
),

child: const Icon(
Icons.workspace_premium,
color: Colors.deepPurple,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
certificate.traineeName,

style: const TextStyle(
fontWeight:
FontWeight.bold,

fontSize: 18,
),
),

const SizedBox(height: 4),

Text(
certificate.courseTitle,
),
],
),
),
],
),

const SizedBox(height: 18),

Text(
'Certificate Code: ${certificate.certificateCode}',
),

const SizedBox(height: 6),

Text(
'Level: ${certificate.levelNumber}',
),

const SizedBox(height: 6),

Text(
'Issued By: ${certificate.issuedBy}',
),

const SizedBox(height: 20),

SizedBox(
width: double.infinity,
height: 50,

child: ElevatedButton.icon(

onPressed: () {

_openCertificate(
certificate
    .fullCertificateUrl,
);
},

icon:
const Icon(Icons.picture_as_pdf),

label: const Text(
'OPEN CERTIFICATE',
),

style: ElevatedButton.styleFrom(
backgroundColor:
Colors.deepPurple,

foregroundColor:
Colors.white,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
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
}

