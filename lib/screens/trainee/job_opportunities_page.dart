// 📄 lib/screens/trainee/job_opportunities_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import '../../bloc/job/job_event.dart';
import '../../bloc/job/job_state.dart';
import '../../models/job_models.dart';

// ============================================================
// 🎯 الشاشة الرئيسية لفرص العمل
// ============================================================
class JobOpportunitiesPage extends StatefulWidget {
  const JobOpportunitiesPage({super.key});

  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  // ============================================================
  // 📌 المتغيرات المستخدمة في الشاشة
  // ============================================================

  // متغير للبحث - يخزن النص الذي يكتبه المستخدم
  String _searchQuery = '';

  // متحكم في حقل النص لإمكانية التحكم به برمجياً (مثل مسح المحتوى)
  final TextEditingController _searchController = TextEditingController();

  // متغير للتحقق مما إذا كانت هذه أول مرة يتم تحميل الصفحة
  bool _isFirstLoad = true;

  // متغير لإظهار مؤشر التحميل أثناء قراءة البيانات من SharedPreferences
  bool _isLoadingPrefs = true;

  // قائمة مؤقتة لحفظ الوظائف التي تم جلبها من الـ API
  List<JobModel> _cachedJobs = [];

  // مجموعة لحفظ IDs الوظائف التي تم التقديم عليها - نستخدم Set لأنها أسرع وتضمن عدم التكرار
  Set<String> _appliedJobIds = {};

  // ============================================================
  // 🔄 دورة حياة الشاشة (Lifecycle)
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initialize(); // استدعاء دالة التهيئة عند فتح الشاشة
  }

  // ============================================================
  // 🚀 دالة التهيئة: تحميل البيانات المخزنة ثم جلب الوظائف الجديدة
  // ============================================================
  Future<void> _initialize() async {
    try {
      // الخطوة 1: تحميل IDs الوظائف التي سبق للمستخدم التقديم عليها من الذاكرة المحلية
      await _loadAppliedJobs();
    } catch (e) {
      // في حالة حدوث خطأ، نبدأ بمجموعة فارغة
      _appliedJobIds = {};
    } finally {
      // إخفاء مؤشر التحميل بعد الانتهاء (إذا كانت الشاشة لا تزال موجودة)
      if (mounted) setState(() => _isLoadingPrefs = false);
    }
    // الخطوة 2: جلب قائمة الوظائف من الخادم عبر Bloc
    _loadJobs();
  }

  // ============================================================
  // 📥 تحميل IDs الوظائف المخزنة محلياً من SharedPreferences
  // ============================================================
  Future<void> _loadAppliedJobs() async {
    try {
      // الحصول على مثيل من SharedPreferences (ملف التخزين المحلي)
      final prefs = await SharedPreferences.getInstance();
      // قراءة قائمة IDs المخزنة، إذا لم توجد نبدأ بقائمة فارغة
      final applied = prefs.getStringList('applied_jobs') ?? [];
      // تحويل القائمة إلى Set لتسريع عملية البحث ومنع التكرار
      _appliedJobIds = applied.toSet();
      debugPrint("✅ تم تحميل ${_appliedJobIds.length} وظيفة مقدم عليها مسبقاً");
    } catch (e) {
      debugPrint("❌ فشل تحميل التقديمات: $e");
      _appliedJobIds = {};
    }
  }

  // ============================================================
  // 💾 حفظ ID الوظيفة بعد التقديم عليها (لمنع التقديم مرة أخرى)
  // ============================================================
  Future<void> _saveAppliedJob(String jobId) async {
    // الحصول على مثيل SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // إضافة الـ ID الجديد إلى مجموعة IDs المقدّم عليها
    _appliedJobIds.add(jobId);
    // تحويل الـ Set إلى List وحفظه في التخزين المحلي
    await prefs.setStringList('applied_jobs', _appliedJobIds.toList());
    debugPrint("💾 تم حفظ الوظيفة $jobId في قائمة المقدم عليها");
  }

  // ============================================================
  // 🌐 استدعاء الـ Bloc لجلب الوظائف من الخادم
  // ============================================================
  void _loadJobs() {
    // الحصول على حالة المصادقة الحالية من AuthBloc
    final authState = context.read<AuthBloc>().state;
    String userId = '';

    // إذا كان المستخدم مسجلاً دخول، نأخذ معرفه
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    // إرسال حدث تحميل الوظائف إلى JobBloc مع userId (قد يستخدم لعرض وظائف مخصصة)
    context.read<JobBloc>().add(LoadJobsEvent(userId: userId));
  }

  // ============================================================
  // 🔍 البحث في الوظائف حسب النص المدخل
  // ============================================================
  void _searchJobs() {
    // إرسال حدث البحث إلى JobBloc مع كلمة البحث وبدون تصنيف
    context.read<JobBloc>().add(SearchJobsEvent(query: _searchQuery, category: null));
  }

  // ============================================================
  // 🧹 مسح محتوى حقل البحث وإعادة تعيين النتائج
  // ============================================================
  void _clearSearch() {
    setState(() {
      _searchQuery = '';           // تفريغ متغير البحث
      _searchController.clear();   // تفريغ حقل النص
    });
    // إرسال حدث بحث فارغ لإعادة عرض جميع الوظائف
    context.read<JobBloc>().add(const SearchJobsEvent(query: '', category: null));
  }

  // ============================================================
  // 📱 عرض نافذة منبثقة تحتوي على تفاصيل الوظيفة
  // ============================================================
  void _showJobDetails(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,        // يسمح للسحب لأعلى لجعل المحتوى قابل للتمرير
      backgroundColor: Colors.transparent, // خلفية شفافة لتظهر النافذة بشكل جميل
      builder: (context) => JobDetailSheet(
        job: job,
        // نمرر قيمة تحدد ما إذا كان المستخدم قد تقدم لهذه الوظيفة من قبل
        isPersistedApplied: _appliedJobIds.contains(job.id),
        // نمرر دالة ليتم استدعاؤها عند تغيير حالة الوظيفة (بعد التقديم)
        onJobStatusChanged: _updateJobStatus,
      ),
    );
  }

  // ============================================================
  // 🔄 تحديث حالة الوظيفة بعد نجاح عملية التقديم
  // ============================================================
  void _updateJobStatus(String jobId, bool isApplied) {
    setState(() {
      if (isApplied) {
        _appliedJobIds.add(jobId); // إضافة الـ ID إلى قائمة المقدم عليها
      }
    });
    _saveAppliedJob(jobId); // حفظ التغييرات في التخزين المحلي فوراً
  }

  // ============================================================
  // ♻️ تنظيف الموارد عند إغلاق الشاشة
  // ============================================================
  @override
  void dispose() {
    _searchController.dispose(); // تحرير متحكم حقل النص
    super.dispose();
  }

  // ============================================================
  // 🎨 بناء واجهة المستخدم الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // إذا كنا لا نزال نحمل البيانات من SharedPreferences، نعرض مؤشر تحميل
    if (_isLoadingPrefs) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // تغيير النص من "Fashion Jobs" إلى "Job Opportunities" كما طلبت
        title: const Text(
          'Job Opportunities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 🎨 تدرج لوني من deepPurple إلى purple كما طلبت
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        // 🏹 تغيير لون سهم الرجوع إلى الأبيض
        iconTheme: const IconThemeData(color: Colors.white),
        // إضافة حقل البحث أسفل الـ AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55), // تصغير ارتفاع حقل البحث
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10), // تقليل padding الجانبي
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for jobs...',
                hintStyle: const TextStyle(fontSize: 13), // تصغير حجم النص الإرشادي
                prefixIcon: const Icon(Icons.search, size: 18), // تصغير حجم أيقونة البحث
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18), // تصغير حجم أيقونة المسح
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8), // تقليل الارتفاع الداخلي
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25), // تقليل انحناء الحواف قليلاً
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchJobs();
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<JobBloc, JobState>(
        // 👂 الاستماع للأحداث التي ترجع من الـ Bloc لعرض رسائل للمستخدم
        listener: (context, state) {
          if (state is JobApplied) {
            // عند نجاح عملية التقديم على وظيفة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Application submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is JobError) {
            // عند حدوث خطأ ما
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // 🏗️ بناء واجهة المستخدم بناءً على حالة الـ Bloc
        builder: (context, state) {
          // ============================================================
          // حالة 1: جاري تحميل الوظائف لأول مرة
          // ============================================================
          if (state is JobLoading && _isFirstLoad) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          // ============================================================
          // حالة 2: تم تحميل الوظائف بنجاح من الخادم
          // ============================================================
          if (state is JobsLoaded) {
            _isFirstLoad = false;

            // دمج حالة التقديم المحفوظة (من SharedPreferences) مع الوظائف القادمة من الـ API
            _cachedJobs = state.jobs.map((job) {
              // إذا كان ID الوظيفة موجوداً في قائمة المقدم عليها مسبقاً
              if (_appliedJobIds.contains(job.id)) {
                // نعيد نسخة من الوظيفة مع تعيين isApplied = true
                return job.copyWith(isApplied: true);
              }
              return job;
            }).toList();
          }

          // ============================================================
          // حالة 3: لا توجد وظائف متاحة للعرض
          // ============================================================
          if (_cachedJobs.isEmpty && !(state is JobLoading)) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No jobs available right now',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ============================================================
          // حالة 4: عرض قائمة الوظائف (الحالة الطبيعية)
          // ============================================================
          return RefreshIndicator(
            // تحديث البيانات عند سحب الشاشة للأسفل
            onRefresh: () async {
              _loadJobs();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cachedJobs.length,
              itemBuilder: (context, index) {
                final job = _cachedJobs[index];
                // متغير منطقي يحدد ما إذا كان المستخدم قد تقدم لهذه الوظيفة
                final alreadyApplied = _appliedJobIds.contains(job.id);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    // أيقونة أو شعار الشركة على اليسار
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          job.companyLogo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(job.company),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(job.location,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 12),
                            const Icon(Icons.attach_money,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(job.salary,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    // إذا كان قد تقدم مسبقاً → نعطل الـ onTap (لا يمكن فتح التفاصيل)
                    // وإلا → نسمح بفتح التفاصيل للتقديم
                    onTap: alreadyApplied ? null : () => _showJobDetails(job),
                    // في الجانب الأيمن: إذا كان مقدم عليه نعرض علامة "Applied"، وإلا نعرض سهم
                    trailing: alreadyApplied
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Applied ✓",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.deepPurple),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 💼 نافذة تفاصيل الوظيفة (Bottom Sheet) - تظهر عند الضغط على وظيفة
// ============================================================
class JobDetailSheet extends StatefulWidget {
  final JobModel job;                              // بيانات الوظيفة
  final bool isPersistedApplied;                  // هل تم التقديم مسبقاً (من SharedPreferences)؟
  final Function(String, bool) onJobStatusChanged; // دالة لإعلام الشاشة الرئيسية بتغير الحالة

  const JobDetailSheet({
    super.key,
    required this.job,
    required this.isPersistedApplied,
    required this.onJobStatusChanged,
  });

  @override
  State<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<JobDetailSheet> {
  bool _isProcessing = false;  // لمنع الضغط المتكرر على زر التقديم أثناء المعالجة
  late bool _localIsApplied;    // الحالة المحلية للزر (مقدم عليه أم لا)

  @override
  void initState() {
    super.initState();
    // تحديد الحالة الابتدائية للزر
    // إذا كان مقدم عليه من قبل (من SharedPreferences) أو الوظيفة نفسها تقول ذلك
    _localIsApplied = widget.isPersistedApplied || widget.job.isApplied;
  }

  // ============================================================
  // 🚀 دالة التقديم على الوظيفة
  // ============================================================
  void _applyForJob() {
    // منع التقديم إذا:
    // 1. جاري المعالجة بالفعل
    // 2. تم التقديم مسبقاً (الزر معطل)
    if (_isProcessing || _localIsApplied) return;

    // الحصول على حالة المصادقة الحالية
    final authState = context.read<AuthBloc>().state;

    // التأكد من أن المستخدم مسجل دخول
    if (authState is AuthAuthenticated) {
      // تفعيل حالة المعالجة وتغيير مظهر الزر
      setState(() {
        _isProcessing = true;
        _localIsApplied = true;
      });

      // الخطوة 1: حفظ الحالة محلياً في SharedPreferences فوراً لمنع التقديم المزدوج
      widget.onJobStatusChanged(widget.job.id, true);

      // الخطوة 2: إرسال الحدث إلى الـ Bloc للتسجيل في الخادم
      context.read<JobBloc>().add(
        ApplyForJobEvent(
          jobId: widget.job.id,
          userId: authState.user.id,
          userName: authState.user.name,
          userEmail: authState.user.email,
        ),
      );

      // الخطوة 3: إغلاق النافذة بعد نصف ثانية مع عرض رسالة نجاح
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // إغلاق النافذة المنبثقة
        }
      });
    } else {
      // إذا لم يكن المستخدم مسجل دخول، نعرض رسالة تنبيه
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please login first to apply'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ============================================================
  // 🎨 بناء واجهة نافذة التفاصيل
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,  // الحجم الابتدائي (85% من الشاشة)
      minChildSize: 0.5,       // أصغر حجم يمكن السحب إليه (50%)
      maxChildSize: 0.95,      // أكبر حجم يمكن السحب إليه (95%)
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // شريط السحب (Drag Handle) - يظهر في أعلى النافذة
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // المحتوى القابل للتمرير
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شعار الشركة (دائري ملون)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.deepPurple, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.job.companyLogo,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // عنوان الوظيفة
                    Center(
                      child: Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // اسم الشركة
                    Center(
                      child: Text(
                        widget.job.company,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // عرض تفاصيل الوظيفة في صفوف منظمة
                    _buildInfoRow(Icons.location_on, 'Location', widget.job.location),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.attach_money, 'Salary', widget.job.salary),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.work, 'Job Type', widget.job.type),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.timeline, 'Experience', widget.job.experience),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Deadline',
                      _formatDate(widget.job.deadline),
                    ),
                    const Divider(height: 32),
                    // قسم وصف الوظيفة
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    // قسم متطلبات الوظيفة (قائمة نقطية)
                    const Text(
                      'Requirements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.job.requirements.map(
                          (req) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(req, style: const TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // زر التقديم الرئيسي
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // الزر يكون معطل إذا:
                        // - تم التقديم مسبقاً (_localIsApplied = true)
                        // - أو جاري معالجة الطلب (_isProcessing = true)
                        onPressed:
                        _localIsApplied || _isProcessing ? null : _applyForJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _localIsApplied ? Colors.grey : Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          _localIsApplied ? '✓ Applied' : 'Apply Now',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏗️ دالة مساعدة لبناء صف المعلومات (أيقونة + تسمية + قيمة)
  // ============================================================
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  // ============================================================
  // 📅 دالة مساعدة لتنسيق التاريخ (يوم/شهر/سنة)
  // ============================================================
  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}