import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import '../widgets/sketch_pad.dart';
import 'note_editor_screen.dart';

class DailyNotesScreen extends StatefulWidget {
  const DailyNotesScreen({Key? key}) : super(key: key);

  @override
  State<DailyNotesScreen> createState() => _DailyNotesScreenState();
}

class _DailyNotesScreenState extends State<DailyNotesScreen> {
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Semua';
  List<String> _pinnedNoteIds = [];

  // State untuk pengaturan harian catatan
  String _defaultCategory = 'Umum';
  bool _isSortDesc = true;

  final List<String> _categories = const [
    'Semua',
    'Umum',
    'Budidaya',
    'Hama & Penyakit',
    'Pemupukan',
    'Irigasi'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotesAndSettings();
  }

  Future<void> _loadNotesAndSettings() async {
    setState(() => _isLoading = true);
    // 1. Ambil Pengaturan dari SharedPreferences
    _defaultCategory = await SharedPrefsHelper.getNotesDefaultCategory();
    _isSortDesc = await SharedPrefsHelper.isNotesSortByDateDesc();

    final prefs = await SharedPreferences.getInstance();
    _pinnedNoteIds = prefs.getStringList('pinned_note_ids') ?? [];

    // 2. Ambil Catatan dari SQLite
    final notes = await DatabaseHelper.instance.getDailyNotes();
    
    setState(() {
      _allNotes = List<Map<String, dynamic>>.from(notes);
      _isLoading = false;
    });
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    List<Map<String, dynamic>> temp = List.from(_allNotes);

    // Filter Kategori
    if (_selectedCategoryFilter != 'Semua') {
      temp = temp.where((n) => n['category'] == _selectedCategoryFilter).toList();
    }

    // Filter Pencarian
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      temp = temp.where((n) {
        final title = (n['title'] as String).toLowerCase();
        final content = (n['content'] as String).toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    }

    // Urutkan Tanggal dan Pin
    temp.sort((a, b) {
      final idA = (a['id'] as int).toString();
      final idB = (b['id'] as int).toString();
      final isPinnedA = _pinnedNoteIds.contains(idA);
      final isPinnedB = _pinnedNoteIds.contains(idB);

      if (isPinnedA && !isPinnedB) return -1;
      if (!isPinnedA && isPinnedB) return 1;

      final dateA = a['date'] as String;
      final dateB = b['date'] as String;
      if (_isSortDesc) {
        return dateB.compareTo(dateA); // Terbaru dahulu
      } else {
        return dateA.compareTo(dateB); // Terlama dahulu
      }
    });

    setState(() {
      _filteredNotes = temp;
    });
  }

  Future<void> _deleteNoteItem(int id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Catatan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
        content: Text('Apakah Anda yakin ingin menghapus catatan "$title"?', style: const TextStyle(color: AppColors.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textLight)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteDailyNote(id);
      _showSnackBar('Catatan terhapus');
      _loadNotesAndSettings();
    }
  }

  Future<void> _togglePinNote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final idStr = id.toString();
    setState(() {
      if (_pinnedNoteIds.contains(idStr)) {
        _pinnedNoteIds.remove(idStr);
        _showSnackBar('Catatan dilepas pin');
      } else {
        _pinnedNoteIds.add(idStr);
        _showSnackBar('Catatan disematkan');
      }
    });
    await prefs.setStringList('pinned_note_ids', _pinnedNoteIds);
    _applyFilterAndSort();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textCharcoal,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 24),
                    const Text('Pengaturan Catatan Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                    const SizedBox(height: 20),

                    // Kategori Bawaan (Default)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategori Default', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                            Text('Kategori awal saat membuat catatan baru', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _defaultCategory,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textCharcoal),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              items: _categories.where((cat) => cat != 'Semua').map((String cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) async {
                                if (val != null) {
                                  setModalState(() => _defaultCategory = val);
                                  setState(() => _defaultCategory = val);
                                  await SharedPrefsHelper.setNotesDefaultCategory(val);
                                  _showSnackBar('Kategori default diatur ke $val');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColors.cardLightGrey.withOpacity(0.8), height: 1),
                    const SizedBox(height: 16),

                    // Urutan Tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Urutkan Berdasarkan Tanggal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal)),
                            Text('Arah sorting urutan waktu catatan', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<bool>(
                              value: _isSortDesc,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textCharcoal),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              items: const [
                                DropdownMenuItem<bool>(value: true, child: Text('Terbaru dahulu')),
                                DropdownMenuItem<bool>(value: false, child: Text('Terlama dahulu')),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  setModalState(() => _isSortDesc = val);
                                  setState(() => _isSortDesc = val);
                                  await SharedPrefsHelper.setNotesSortByDateDesc(val);
                                  _applyFilterAndSort();
                                  _showSnackBar('Urutan catatan diperbarui');
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            'Catatan Harian',
            style: TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textCharcoal),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.cardLightGrey, height: 1.0),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textCharcoal),
              onPressed: _showSettingsBottomSheet,
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryGreen,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
            );
            if (result == true) {
              _loadNotesAndSettings();
            }
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    child: Column(
                      children: [
                        // Search bar input
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.cardLightGrey, borderRadius: BorderRadius.circular(50)),
                            child: TextField(
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                                _applyFilterAndSort();
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Cari judul atau isi catatan...',
                                hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 13),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),

                        // Horisontal filter Kategori chips
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategoryFilter == cat;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.textCharcoal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryGreen,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : AppColors.cardLightGrey,
                                      width: 1,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedCategoryFilter = cat);
                                      _applyFilterAndSort();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List of Catatan
                        Expanded(
                          child: _filteredNotes.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: _filteredNotes.length,
                                  itemBuilder: (context, index) {
                                    final note = _filteredNotes[index];
                                    final int id = note['id'] as int;
                                    final String title = note['title'] as String;
                                    final String category = note['category'] as String;
                                    final String date = note['date'] as String;
                                    final String snippet = note['content'] as String;
                                    final isPinned = _pinnedNoteIds.contains(id.toString());

                                    return Slidable(
                                      key: ValueKey(id),
                                      startActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.5,
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              Share.share(
                                                'Catatan: $title\nKategori: $category\nTanggal: $date\n\n$snippet',
                                                subject: title,
                                              );
                                            },
                                            backgroundColor: AppColors.primaryGreen,
                                            foregroundColor: Colors.white,
                                            icon: Icons.share_rounded,
                                            label: 'Share',
                                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                          ),
                                          SlidableAction(
                                            onPressed: (context) => _togglePinNote(id),
                                            backgroundColor: Colors.amber.shade700,
                                            foregroundColor: Colors.white,
                                            icon: _pinnedNoteIds.contains(id.toString())
                                                ? Icons.push_pin_rounded
                                                : Icons.push_pin_outlined,
                                            label: _pinnedNoteIds.contains(id.toString()) ? 'Unpin' : 'Pin',
                                          ),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.25,
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) => _deleteNoteItem(id, title),
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete_outline_rounded,
                                            label: 'Hapus',
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: isPinned ? const Color(0xFFFFFBEA) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isPinned
                                                  ? Colors.amber.withOpacity(0.03)
                                                  : Colors.black.withOpacity(0.02),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                          border: Border.all(
                                            color: isPinned
                                                ? const Color(0xFFFFD54F)
                                                : AppColors.dividerGrey.withOpacity(0.4),
                                            width: isPinned ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
                                              );
                                              if (result == true) {
                                                _loadNotesAndSettings();
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primaryGreen.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          category,
                                                          style: const TextStyle(fontSize: 9, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      if (_pinnedNoteIds.contains(id.toString()))
                                                        const Icon(
                                                          Icons.push_pin_rounded,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    title,
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    snippet,
                                                    style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (note['drawing_path'] != null && (note['drawing_path'] as String).isNotEmpty) ...[
                                                    const SizedBox(height: 10),
                                                    SketchThumbnailPreview(
                                                      drawingData: note['drawing_path'] as String,
                                                      height: 80,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textLight),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        date,
                                                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Catatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tulis catatan harian seputar budidaya atau pengelolaan sorgum Anda sekarang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}