import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/database_helper.dart';
import '../../data/helpers/shared_prefs_helper.dart';
import '../widgets/sketch_pad.dart';
import '../widgets/sketch_pad.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note; // Jika null, berarti Create, jika tidak null berarti Update
  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedCategory = 'Umum';
  bool _isLoading = true;
  String _drawingPath = '';
  bool _showSketchPad = false;

  final List<String> _categories = const [
    'Umum',
    'Budidaya',
    'Hama & Penyakit',
    'Pemupukan',
    'Irigasi'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?['title'] ?? '');
    _contentController = TextEditingController(text: widget.note?['content'] ?? '');
    _initCategory();
  }

  Future<void> _initCategory() async {
    if (widget.note != null) {
      final noteCat = widget.note!['category'] as String;
      _drawingPath = widget.note!['drawing_path'] as String? ?? '';
      setState(() {
        _selectedCategory = _categories.contains(noteCat) ? noteCat : _categories.first;
        _showSketchPad = _drawingPath.isNotEmpty;
        _isLoading = false;
      });
    } else {
      final defaultCat = await SharedPrefsHelper.getNotesDefaultCategory();
      setState(() {
        _selectedCategory = _categories.contains(defaultCat) ? defaultCat : _categories.first;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final String dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    final Map<String, dynamic> noteData = {
      'title': title,
      'category': _selectedCategory,
      'content': content,
      'date': dateStr,
      'drawing_path': _drawingPath,
    };

    if (widget.note != null) {
      noteData['id'] = widget.note!['id'];
      await DatabaseHelper.instance.updateDailyNote(noteData);
      _showSnackBar('Catatan berhasil diperbarui!');
    } else {
      await DatabaseHelper.instance.insertDailyNote(noteData);
      _showSnackBar('Catatan berhasil ditambahkan!');
    }

    if (mounted) {
      Navigator.pop(context, true); // Kembali dengan boolean true agar list di-refresh
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textCharcoal,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.note != null;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Catatan' : 'Catatan Baru',
            style: const TextStyle(color: AppColors.textCharcoal, fontSize: 18, fontWeight: FontWeight.bold),
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
              icon: const Icon(Icons.check_rounded, color: AppColors.primaryGreen, size: 28),
              onPressed: _saveNote,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          // input judul
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                            decoration: InputDecoration(
                              hintText: 'Judul Catatan...',
                              hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Judul tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // selector kategori
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.label_outline_rounded, size: 16, color: AppColors.primaryGreen),
                                    const SizedBox(width: 6),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCategory,
                                        isDense: true,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                        items: _categories.map((String cat) {
                                          return DropdownMenuItem<String>(
                                            value: cat,
                                            child: Text(cat),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _selectedCategory = val);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: AppColors.cardLightGrey.withOpacity(0.8), height: 1),
                          const SizedBox(height: 16),

                          // input isi catatan
                          TextFormField(
                            controller: _contentController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(fontSize: 14, color: AppColors.textCharcoal, height: 1.5),
                            decoration: InputDecoration(
                              hintText: 'Mulai menulis catatan Anda di sini...',
                              hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Isi catatan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_showSketchPad) ...[
                             SketchDrawingPad(
                              initialDrawingData: _drawingPath,
                              onSaved: (jsonStr) {
                                setState(() {
                                  _drawingPath = jsonStr;
                                });
                                _showSnackBar('Tanda tangan berhasil disimpan ke memori catatan harian!');
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('Hapus Tanda Tangan Dari Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  setState(() {
                                    _drawingPath = '';
                                    _showSketchPad = false;
                                  });
                                },
                              ),
                            ),
                          ] else ...[
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                side: const BorderSide(color: AppColors.primaryGreen),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.draw_rounded, size: 18),
                              label: const Text('Lampirkan Tanda Tangan', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                setState(() {
                                  _showSketchPad = true;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
