//lib/screens/trainee/trainee_certificates_page.dart


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/certificate/certificate_bloc.dart';
import '../../bloc/certificate/certificate_event.dart';
import '../../bloc/certificate/certificate_state.dart';

import '../../models/course_models.dart';
import '../../repositories/course_repository.dart';

class TraineeCertificatesPage extends StatefulWidget {
const TraineeCertificatesPage({super.key});

@override
State<TraineeCertificatesPage> createState() =>
_TraineeCertificatesPageState();
}

class _TraineeCertificatesPageState
extends State<TraineeCertificatesPage> {

List<CourseItem> _courses = [];

@override
void initState() {
super.initState();

context.read<CertificateBloc>()
    .add(LoadMyCertificatesEvent());

_loadCourses();
}

Future<void> _loadCourses() async {
final courses =
await CourseRepository().loadRegisteredCourses('');

setState(() {
_courses = courses;
});
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
'My Certificates',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),

body: BlocConsumer<CertificateBloc, CertificateState>(

listener: (context, state) {

if (state is CertificateError) {

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: Colors.red,
content: Text(state.message),
),
);
}

if (state is CertificateSuccess) {

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
backgroundColor: Colors.green,
content: Text(state.message),
),
);
}
},

builder: (context, state) {

// ===================================================
// Loading
// ===================================================

if (state is CertificateLoading) {

return const Center(
child: CircularProgressIndicator(
color: Colors.deepPurple,
),
);
}

// ===================================================
// Loaded
// ===================================================

if (state is CertificateLoaded) {

final certificates = state.certificates;

return SingleChildScrollView(
padding: const EdgeInsets.all(16),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

// ============================================
// Generate Buttons
// ============================================

const Text(
'Generate Certificate',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),

const SizedBox(height: 14),

..._courses.map((course) {

return Container(
margin: const EdgeInsets.only(bottom: 14),

padding: const EdgeInsets.all(18),

decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),

boxShadow: [
BoxShadow(
color: Colors.deepPurple.withOpacity(0.08),
blurRadius: 10,
offset: const Offset(0, 5),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
course.title,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
'Level ${course.levelNumber}',
style: TextStyle(
color: Colors.grey.shade700,
),
),

const SizedBox(height: 16),

SizedBox(
width: double.infinity,
height: 50,

child: ElevatedButton.icon(

onPressed: () {

context
    .read<CertificateBloc>()
    .add(
GenerateCertificateEvent(
levelNumber:
course.levelNumber,
),
);
},

icon: const Icon(Icons.workspace_premium),

label: const Text(
'Generate Certificate',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

style: ElevatedButton.styleFrom(
backgroundColor:
Colors.deepPurple,

foregroundColor: Colors.white,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
),
),
),
],
),
);
}),

const SizedBox(height: 24),

// ============================================
// My Certificates
// ============================================

const Text(
'My Certificates',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),

const SizedBox(height: 16),

if (certificates.isEmpty)

Container(
width: double.infinity,
padding: const EdgeInsets.all(30),

decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
),

child: const Column(
children: [

Icon(
Icons.workspace_premium_outlined,
size: 70,
color: Colors.deepPurple,
),

SizedBox(height: 14),

Text(
'No certificates yet',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
],
),
)

else

...certificates.map((certificate) {

return Container(
margin: const EdgeInsets.only(bottom: 18),

decoration: BoxDecoration(
borderRadius:
BorderRadius.circular(24),

gradient: const LinearGradient(
colors: [
Colors.deepPurple,
Colors.purple,
],
),

boxShadow: [
BoxShadow(
color:
Colors.deepPurple.withOpacity(0.2),

blurRadius: 10,
offset: const Offset(0, 5),
),
],
),

child: Padding(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Row(
children: [

Container(
padding:
const EdgeInsets.all(12),

decoration: BoxDecoration(
color: Colors.white
    .withOpacity(0.15),

borderRadius:
BorderRadius.circular(14),
),

child: const Icon(
Icons.workspace_premium,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
certificate.courseTitle,

style: const TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
certificate.certificateCode,

style: TextStyle(
color: Colors.white
    .withOpacity(0.9),
),
),
],
),
),
],
),

const SizedBox(height: 20),

_buildInfo(
'Student',
certificate.traineeName,
),

_buildInfo(
'Level',
certificate.levelNumber.toString(),
),

_buildInfo(
'Issued By',
certificate.issuedBy,
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

icon: const Icon(Icons.picture_as_pdf),

label: const Text(
'OPEN CERTIFICATE',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,

foregroundColor:
Colors.deepPurple,

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
}),
],
),
);
}

return const SizedBox();
},
),
);
}

Widget _buildInfo(String title, String value) {

return Padding(
padding: const EdgeInsets.only(bottom: 8),

child: Row(
children: [

Text(
'$title: ',
style: const TextStyle(
color: Colors.white70,
fontWeight: FontWeight.bold,
),
),

Expanded(
child: Text(
value,

style: const TextStyle(
color: Colors.white,
),
),
),
],
),
);
}
}

