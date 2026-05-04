import 'package:flutter/material.dart';
// ==================== صفحة فرص العمل (Job Opportunities) ====================
class JobOpportunitiesPage extends StatefulWidget {
  const JobOpportunitiesPage({super.key});

  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  // متغير للبحث
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // متغير للفلترة حسب النوع
  String _selectedFilter = 'All';

  // قائمة أنواع الوظائف للفلترة
  final List<String> _filters = ['All', 'Remote', 'Full-time', 'Part-time', 'Internship'];

  // بيانات فرص العمل (بدون const)
  final List<Map<String, dynamic>> allJobs = [
    {
      'title': 'Flutter Developer',
      'company': 'Tech Solutions',
      'location': 'Remote',
      'type': 'Full-time',
      'salary': '\$5,000 - \$7,000',
      'description': 'We are looking for a skilled Flutter developer to join our team...',
      'requirements': '3+ years experience in Flutter, Dart, API integration',
      'postedDate': '2 days ago',
      'logo': Icons.code,
      'color': 0xFF6C63FF,
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Creative Studio',
      'location': 'Dubai, UAE',
      'type': 'Full-time',
      'salary': '\$4,000 - \$6,000',
      'description': 'Seeking a creative UI/UX designer with a passion for beautiful designs...',
      'requirements': 'Figma, Adobe XD, portfolio required',
      'postedDate': '5 days ago',
      'logo': Icons.design_services,
      'color': 0xFFFF6B6B,
    },
    {
      'title': 'Backend Developer',
      'company': 'Cloud Systems',
      'location': 'Remote',
      'type': 'Remote',
      'salary': '\$6,000 - \$8,000',
      'description': 'Looking for backend developer experienced in Node.js and databases...',
      'requirements': 'Node.js, MongoDB, Express, API design',
      'postedDate': '1 week ago',
      'logo': Icons.cloud,
      'color': 0xFF4ECDC4,
    },
    {
      'title': 'Product Manager',
      'company': 'Startup Hub',
      'location': 'Riyadh, KSA',
      'type': 'Full-time',
      'salary': '\$7,000 - \$10,000',
      'description': 'Lead product development and coordinate with cross-functional teams...',
      'requirements': '3+ years product management experience, Agile methodology',
      'postedDate': '3 days ago',
      'logo': Icons.analytics,
      'color': 0xFFFFB347,
    },
    {
      'title': 'Frontend Intern',
      'company': 'Web Masters',
      'location': 'Remote',
      'type': 'Internship',
      'salary': '\$1,000 - \$1,500',
      'description': 'Learn and grow with our frontend team. Great opportunity for fresh graduates...',
      'requirements': 'HTML, CSS, JavaScript basics',
      'postedDate': '1 day ago',
      'logo': Icons.web,
      'color': 0xFF9B59B6,
    },
    {
      'title': 'Data Analyst',
      'company': 'Data Corp',
      'location': 'Abu Dhabi, UAE',
      'type': 'Part-time',
      'salary': '\$3,000 - \$4,500',
      'description': 'Analyze data and create reports for business decisions...',
      'requirements': 'SQL, Python, Excel, Power BI',
      'postedDate': '4 days ago',
      'logo': Icons.bar_chart,
      'color': 0xFF2ECC71,
    },
    {
      'title': 'Mobile Developer (iOS)',
      'company': 'App Factory',
      'location': 'Remote',
      'type': 'Full-time',
      'salary': '\$5,500 - \$7,500',
      'description': 'Develop high-quality iOS applications using Swift...',
      'requirements': 'Swift, iOS SDK, MVVM pattern',
      'postedDate': '6 days ago',
      'logo': Icons.phone_iphone,
      'color': 0xFFE74C3C,
    },
    {
      'title': 'DevOps Engineer',
      'company': 'Tech Innovators',
      'location': 'Dubai, UAE',
      'type': 'Remote',
      'salary': '\$8,000 - \$11,000',
      'description': 'Manage cloud infrastructure and CI/CD pipelines...',
      'requirements': 'AWS, Docker, Kubernetes, Jenkins',
      'postedDate': '2 weeks ago',
      'logo': Icons.devices,
      'color': 0xFF1ABC9C,
    },
  ];

  // دالة لفلترة الوظائف حسب البحث والنوع
  List<Map<String, dynamic>> get _filteredJobs {
    var jobs = List<Map<String, dynamic>>.from(allJobs);

    // فلترة حسب النوع
    if (_selectedFilter != 'All') {
      jobs = jobs.where((job) => job['type'] == _selectedFilter).toList();
    }

    // فلترة حسب البحث
    if (_searchQuery.isNotEmpty) {
      jobs = jobs.where((job) {
        return job['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job['company'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return jobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Opportunities',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by job title, company, or location...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ==================== أزرار الفلترة ====================
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                        width: isSelected ? 0 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // عدد النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredJobs.length} jobs found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear all filters'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // قائمة الوظائف
          Expanded(
            child: _filteredJobs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة الوظيفة
  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(job: job),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(job['color']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        job['logo'] as IconData,
                        color: Color(job['color']),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job['company'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(job['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job['type'],
                        style: TextStyle(
                          fontSize: 11,
                          color: _getTypeColor(job['type']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      job['location'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      job['salary'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      job['postedDate'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  job['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailPage(job: job),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        ),
                        child: const Text('Apply Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لتحديد لون نوع الوظيفة
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Remote':
        return Colors.green;
      case 'Full-time':
        return Colors.blue;
      case 'Part-time':
        return Colors.orange;
      case 'Internship':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// ==================== صفحة تفاصيل الوظيفة ====================
class JobDetailPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          job['title'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(job['color']).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      job['logo'] as IconData,
                      color: Color(job['color']),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['company'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(job['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job['type'],
                      style: TextStyle(
                        color: _getTypeColor(job['type']),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          Icons.location_on,
                          'Location',
                          job['location'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          Icons.attach_money,
                          'Salary',
                          job['salary'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    Icons.access_time,
                    'Posted',
                    job['postedDate'],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['requirements'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showApplyDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Remote':
        return Colors.green;
      case 'Full-time':
        return Colors.blue;
      case 'Part-time':
        return Colors.orange;
      case 'Internship':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply for this job'),
          content: const Text('Are you sure you want to apply for this position? We will notify the employer about your interest.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}