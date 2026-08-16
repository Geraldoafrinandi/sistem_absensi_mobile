import 'package:flutter/material.dart';
import 'package:frontend_mahasiswa/modules/schedule/data/course_schedule_model.dart';
import 'package:frontend_mahasiswa/modules/schedule/widgets/schedule_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/schedule_service.dart';


class AllCoursesPage extends StatefulWidget {
  const AllCoursesPage({super.key});

  @override
  State<AllCoursesPage> createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  List<CourseScheduleModel> _allCourses = [];
  List<CourseScheduleModel> _filteredCourses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ScheduleService.getMySchedules();
      setState(() {
        _allCourses = data;
        _filteredCourses = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCourses = _allCourses
          .where((c) => c.subject.toLowerCase().contains(query.toLowerCase()) || 
                         c.lecturer.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Semua Mata Kuliah", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? const Center(child: Text("Mata kuliah tidak ditemukan"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) => ScheduleCard(data: _filteredCourses[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: "Cari mata kuliah atau dosen...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B4EFF)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}