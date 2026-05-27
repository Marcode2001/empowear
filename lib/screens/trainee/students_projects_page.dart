//lib/screens/trainee/students_projects_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/previous_student_work/previous_student_work_bloc.dart';
import '../../models/previous_student_work_model.dart';

class StudentsProjectsPage extends StatefulWidget {
  const StudentsProjectsPage({super.key});

  @override
  State<StudentsProjectsPage> createState() =>
      _StudentsProjectsPageState();
}

class _StudentsProjectsPageState
    extends State<StudentsProjectsPage> {

  @override
  void initState() {
    super.initState();

    context.read<PreviousWorkBloc>()
        .add(const LoadPreviousWorkEvent());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Students Projects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),

      body: BlocConsumer<PreviousWorkBloc, PreviousWorkState>(

        listener: (context, state) {

          if (state is PreviousWorkError) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {

          // ================= LOADING =================

          if (state is PreviousWorkLoading) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ================= ERROR =================

          if (state is PreviousWorkError) {

            return Center(
              child: Text(state.message),
            );
          }

          // ================= SUCCESS =================

          if (state is PreviousWorkLoaded) {

            final projects = state.projects;

            if (projects.isEmpty) {

              return const Center(
                child: Text('No Projects Yet'),
              );
            }

            return GridView.builder(

              padding: const EdgeInsets.all(16),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),

              itemCount: projects.length,

              itemBuilder: (context, index) {

                final project = projects[index];

                return _buildProjectCard(project);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProjectCard(PreviousStudentWork project) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProjectDetailPage(project: project),
          ),
        );
      },

      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // IMAGE

            Expanded(

              child: ClipRRect(

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),

                child: Image.network(

                  project.imageUrl,

                  width: double.infinity,
                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) {

                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ),

            // INFO

            Padding(
              padding: const EdgeInsets.all(10),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Student Project',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    project.designerName,

                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// DETAILS PAGE
// =====================================================

class ProjectDetailPage extends StatelessWidget {

  final PreviousStudentWork project;

  const ProjectDetailPage({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Student Project'),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Image.network(

              project.imageUrl,

              width: double.infinity,
              height: 350,

              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) {

                return Container(
                  height: 350,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 80),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(

                    'Student Project',

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(

                    children: [

                      const Icon(
                        Icons.person,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(width: 8),

                      Text(

                        project.designerName,

                        style: const TextStyle(
                          fontSize: 16,
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
    );
  }
}