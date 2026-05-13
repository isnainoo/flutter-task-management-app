import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/task.dart';
import '../widgets/app_widgets.dart';
import 'profile_screen.dart'; // <-- Pastikan import ini mengarah ke file profile yang baru dibuat

class TodoScreen extends StatefulWidget {
  final String username;
  final bool isNewUser;

  const TodoScreen({
    super.key,
    required this.username,
    this.isNewUser = false,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> _tasks = [];
  final _taskController = TextEditingController();
  final _linkController = TextEditingController();
  DateTime? _selectedDate;
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    if (widget.isNewUser) {
      final now = DateTime.now();
      _tasks = [
        Task(id: 1, name: 'Membaca buku', deadline: now.subtract(const Duration(days: 1))),
        Task(id: 2, name: 'Mengerjakan tugas kuliah', deadline: now, submissionLink: 'https://elearning.ums.ac.id/'),
        Task(id: 3, name: 'Belajar untuk ujian', deadline: now.add(const Duration(days: 1))),
        Task(id: 4, name: 'PPM kelompok ${widget.username}', deadline: now.add(const Duration(days: 14))),
      ];
      _nextId = 5;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // --- LOGIKA HELPER & UI ---
  String _getDayLabel(DateTime date) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff < 0) return 'Terlambat';
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    return '$diff hari';
  }

  Color _getTagColor(String label) {
    switch (label) {
      case 'Terlambat': return AppColors.tagRed;
      case 'Hari ini': return AppColors.tagAmber;
      case 'Besok': return AppColors.tagGreen;
      default: return AppColors.tagGray;
    }
  }

  Color _getTagBgColor(String label) {
    switch (label) {
      case 'Terlambat': return AppColors.tagRedBg;
      case 'Hari ini': return AppColors.tagAmberBg;
      case 'Besok': return AppColors.tagGreenBg;
      default: return AppColors.tagGrayBg;
    }
  }

  bool _isNearDeadline(Task task) {
    if (task.deadline == null || task.isDone) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final d = DateTime(task.deadline!.year, task.deadline!.month, task.deadline!.day);
    return d.difference(today).inDays <= 1;
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // --- LOGIKA DATA (CRUD & STATISTIK) ---
  int get _onTimeCount {
    return _tasks.where((t) {
      if (!t.isDone || t.completedAt == null) return false;
      if (t.deadline == null) return true;
      final d = DateTime(t.deadline!.year, t.deadline!.month, t.deadline!.day);
      final c = DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day);
      return !c.isAfter(d);
    }).length;
  }

  int get _lateCount => _completedTasks.length - _onTimeCount;

  void _toggleTask(int id) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _tasks[idx].isDone = !_tasks[idx].isDone;
        _tasks[idx].completedAt = _tasks[idx].isDone ? DateTime.now() : null;
      }
    });
  }

  void _addTask() {
    final name = _taskController.text.trim();
    final link = _linkController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _tasks.add(Task(
        id: _nextId++,
        name: name,
        deadline: _selectedDate,
        submissionLink: link.isNotEmpty ? link : null,
      ));
      _taskController.clear();
      _linkController.clear();
      _selectedDate = null;
    });
  }

  void _deleteTask(int id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
  }

  Future<void> _showDeleteConfirmation(Task task) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          ],
        ),
        content: Text('Apakah kamu yakin ingin menghapus tugas "${task.name}"?', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTask(task.id);
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  List<Task> get _sortedTasks {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return sorted;
  }

  List<Task> get _activeTasks => _sortedTasks.where((t) => !t.isDone).toList();
  List<Task> get _completedTasks => _sortedTasks.where((t) => t.isDone).toList();
  List<Task> get _deadlineTasks => _activeTasks.where((t) => _isNearDeadline(t)).toList();
  int get _remainingCount => _activeTasks.length;

  // --- RENDER UI UTAMA ---
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Container(
                color: AppColors.cardBackground,
                child: const TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: [
                    Tab(text: 'Tugas Aktif'),
                    Tab(text: 'Selesai'),
                    Tab(text: 'Statistik'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // TAB 1: TUGAS AKTIF
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_deadlineTasks.isNotEmpty) _buildDeadlineBox(),
                          _buildAddTask(),
                          _buildTaskList(tasks: _activeTasks, emptyMessage: 'Belum ada tugas. Tambahkan sekarang!'),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // TAB 2: TUGAS SELESAI
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTaskList(tasks: _completedTasks, emptyMessage: 'Belum ada tugas yang diselesaikan. Semangat!'),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    // TAB 3: STATISTIK
                    SingleChildScrollView(
                      child: _buildStatistikTab(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildHeader() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('To-Do List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Halo, ${widget.username}! $_remainingCount tugas tersisa', style: AppTextStyles.taskDate),
            ],
          ),
          // --- TOMBOL MENU PROFIL BARU ---
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(username: widget.username))),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deadlineBg,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: AppColors.deadlineAccent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notifications_outlined, size: 14, color: AppColors.deadlineText),
              SizedBox(width: 6),
              Text('Deadline Mendekat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.deadlineText)),
            ],
          ),
          const SizedBox(height: 8),
          ..._deadlineTasks.map((task) {
            final label = _getDayLabel(task.deadline!);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFFAAAAAA)),
                      const SizedBox(width: 8),
                      Text(task.name, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                    ],
                  ),
                  TagBadge(label: label, textColor: _getTagColor(label), bgColor: _getTagBgColor(label)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddTask() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          TextField(
            controller: _taskController,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tambah tugas baru...',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _linkController,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Link pengumpulan (opsional)...',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
              prefixIcon: const Icon(Icons.link, size: 18, color: Color(0xFFBBBBBB)),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.inputBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate != null ? _formatDate(_selectedDate!) : 'dd/mm/yyyy',
                          style: TextStyle(fontSize: 12, color: _selectedDate != null ? AppColors.textPrimary : const Color(0xFFBBBBBB)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addTask,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList({required List<Task> tasks, required String emptyMessage}) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(emptyMessage, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(children: tasks.map((task) => _buildTaskItem(task)).toList()),
    );
  }

  Widget _buildTaskItem(Task task) {
    final label = task.deadline != null ? _getDayLabel(task.deadline!) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: task.isDone ? 0.6 : 1.0,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTask(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: task.isDone ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: task.isDone ? AppColors.primary : const Color(0xFFD8D0F8), width: 2),
                  shape: BoxShape.circle,
                ),
                child: task.isDone ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name, style: task.isDone ? AppTextStyles.taskNameDone : AppTextStyles.taskName),
                  if (task.deadline != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(_formatDate(task.deadline!), style: AppTextStyles.taskDate),
                        if (label != null) ...[
                          const SizedBox(width: 6),
                          TagBadge(label: label, textColor: _getTagColor(label), bgColor: _getTagBgColor(label)),
                        ],
                      ],
                    ),
                  ],
                  if (task.submissionLink != null && task.submissionLink!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.link, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.submissionLink!,
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, decoration: TextDecoration.underline),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFCCCCCC)),
              onPressed: () => _showDeleteConfirmation(task),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistikTab() {
    final total = _completedTasks.length;
    final onTimeWidth = total == 0 ? 0.0 : _onTimeCount / total;
    final lateWidth = total == 0 ? 0.0 : _lateCount / total;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Performa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Selesai', total.toString(), AppColors.primary),
                    _buildStatItem('Tepat Waktu', _onTimeCount.toString(), AppColors.tagGreen),
                    _buildStatItem('Terlambat', _lateCount.toString(), AppColors.tagRed),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Persentase Ketepatan Waktu', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                if (total > 0)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 12,
                          child: Row(
                            children: [
                              if (_onTimeCount > 0) Expanded(flex: _onTimeCount, child: Container(color: AppColors.tagGreen)),
                              if (_lateCount > 0) Expanded(flex: _lateCount, child: Container(color: AppColors.tagRed)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLegend('Tepat Waktu', AppColors.tagGreen, '${(onTimeWidth * 100).toInt()}%'),
                          _buildLegend('Terlambat', AppColors.tagRed, '${(lateWidth * 100).toInt()}%'),
                        ],
                      ),
                    ],
                  )
                else
                  const Text('Belum ada data untuk dianalisis.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, String percent) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label ($percent)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}