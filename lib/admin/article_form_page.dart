import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sorgummi_ai/core/constants/colors.dart';
import 'package:sorgummi_ai/data/helpers/database_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Form Artikel Edukasi (Full-Screen — bebas overflow)
// Dipakai untuk CREATE (existing == null) maupun EDIT (existing != null)
// ─────────────────────────────────────────────────────────────────────────────
class ArticleFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing; // null = mode tambah baru

  const ArticleFormPage({Key? key, this.existing}) : super(key: key);

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ── Controllers Section 1 ──────────────────────────────────────────────────
  final _judulCtrl        = TextEditingController();
  final _estimasiCtrl     = TextEditingController();
  final _badgeCtrl        = TextEditingController();
  String _selectedKategori = 'Hama';
  String _selectedStatus   = 'Active';

  static const List<String> _kategoriOptions = [
    'Masalah Tanah', 'Hama', 'Penanaman', 'Panen', 'Penyimpanan', 'Umum',
  ];

  // ── Controllers Section 2 ──────────────────────────────────────────────────
  final _judulLangkahCtrl = TextEditingController();
  final _masalahCtrl      = TextEditingController();
  final _penyebabCtrl     = TextEditingController();
  final _tipsAhliCtrl     = TextEditingController();

  /// Daftar controller untuk langkah-langkah solusi dinamis
  final List<TextEditingController> _langkahControllers = [];

  // ── Section 3: Thumbnail ───────────────────────────────────────────────────
  String _thumbnailBase64 = '';   // kosong = belum ada gambar
  final ImagePicker _picker = ImagePicker();

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _populateFromExisting();
  }

  void _populateFromExisting() {
    final e = widget.existing;
    if (e == null) {
      // Mode tambah — tambahkan satu langkah kosong sebagai placeholder
      _langkahControllers.add(TextEditingController());
      return;
    }
    // Mode edit — isi semua field dari data yang sudah ada
    _judulCtrl.text        = e['judul']         ?? '';
    _selectedKategori      = e['kategori']       ?? _kategoriOptions.first;
    _selectedStatus        = e['status']         ?? 'Active';
    _estimasiCtrl.text     = e['estimasi_baca']  ?? '';
    _badgeCtrl.text        = e['badge']          ?? '';
    _judulLangkahCtrl.text = e['judul_langkah']  ?? '';
    _masalahCtrl.text      = e['masalah']        ?? '';
    _penyebabCtrl.text     = e['penyebab']       ?? '';
    _tipsAhliCtrl.text     = e['tips_ahli']      ?? '';
    _thumbnailBase64       = e['thumbnail']      ?? '';

    // Parse langkah_solusi dari JSON string
    try {
      final List<dynamic> parsed = jsonDecode(e['langkah_solusi'] ?? '[]');
      for (final step in parsed) {
        _langkahControllers.add(TextEditingController(text: step.toString()));
      }
    } catch (_) {}

    if (_langkahControllers.isEmpty) {
      _langkahControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _estimasiCtrl.dispose();
    _badgeCtrl.dispose();
    _judulLangkahCtrl.dispose();
    _masalahCtrl.dispose();
    _penyebabCtrl.dispose();
    _tipsAhliCtrl.dispose();
    for (final c in _langkahControllers) c.dispose();
    super.dispose();
  }

  // ── Pilih Thumbnail ────────────────────────────────────────────────────────
  Future<void> _pickThumbnail() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _thumbnailBase64 = base64Encode(bytes);
      });
    } catch (e) {
      _showSnack('Gagal memilih gambar: $e', isError: true);
    }
  }

  // ── Tambah / Hapus Langkah Dinamis ─────────────────────────────────────────
  void _addLangkah() {
    setState(() {
      _langkahControllers.add(TextEditingController());
    });
  }

  void _removeLangkah(int index) {
    if (_langkahControllers.length <= 1) return; // minimal 1 langkah
    setState(() {
      _langkahControllers[index].dispose();
      _langkahControllers.removeAt(index);
    });
  }

  // ── Simpan ke Database ─────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Kumpulkan langkah-langkah sebagai JSON array
    final langkahList = _langkahControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final tanggal = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Konten ringkasan (untuk kompatibilitas backward)
    final kontenRingkas =
        '${_masalahCtrl.text.trim()}\n\n${langkahList.join('\n')}';

    final row = <String, dynamic>{
      if (widget.existing != null) 'id': widget.existing!['id'],
      'judul'           : _judulCtrl.text.trim(),
      'kategori'        : _selectedKategori,
      'status'          : _selectedStatus,
      'estimasi_baca'   : _estimasiCtrl.text.trim(),
      'badge'           : _badgeCtrl.text.trim(),
      'judul_langkah'   : _judulLangkahCtrl.text.trim(),
      'masalah'         : _masalahCtrl.text.trim(),
      'penyebab'        : _penyebabCtrl.text.trim(),
      'langkah_solusi'  : jsonEncode(langkahList),
      'tips_ahli'       : _tipsAhliCtrl.text.trim(),
      'konten'          : kontenRingkas,
      'thumbnail'       : _thumbnailBase64,
      'views'           : widget.existing?['views'] ?? 0,
      'tanggal'         : tanggal,
    };

    try {
      if (widget.existing != null) {
        await DatabaseHelper.instance.updateEdukasi(row);
      } else {
        await DatabaseHelper.instance.insertEdukasi(row);
      }
      if (mounted) {
        Navigator.pop(context, true); // true = ada perubahan, trigger refresh
      }
    } catch (e) {
      _showSnack('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.redAccent : AppColors.primaryGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Artikel Edukasi' : 'Tambah Artikel Edukasi',
          style: const TextStyle(
            color: AppColors.textCharcoal, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
          onPressed: () => Navigator.pop(context, false),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      // Tombol Aksi (bottom bar)
      bottomNavigationBar: _BottomActionBar(
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context, false),
        onSave: _save,
        saveLabel: isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN ARTIKEL',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── SECTION 1: Informasi Dasar ──────────────────────────
                  _SectionHeader(
                    number: '1',
                    title: 'Informasi Dasar',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  _FormCard(children: [
                    _fieldLabel('Judul Artikel *'),
                    _textField(
                      controller: _judulCtrl,
                      hint: 'Contoh: Cara Menanam Sorgum yang Benar',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Kategori *'),
                          const SizedBox(height: 6),
                          _dropdown(
                            value: _selectedKategori,
                            items: _kategoriOptions,
                            onChanged: (v) => setState(() => _selectedKategori = v!),
                          ),
                        ],
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Status *'),
                          const SizedBox(height: 6),
                          _dropdown(
                            value: _selectedStatus,
                            items: const ['Active', 'Draft'],
                            onChanged: (v) => setState(() => _selectedStatus = v!),
                          ),
                        ],
                      )),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Estimasi Baca'),
                          _textField(
                            controller: _estimasiCtrl,
                            hint: 'Contoh: 5 Menit',
                          ),
                        ],
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Badge / Label'),
                          _textField(
                            controller: _badgeCtrl,
                            hint: 'Contoh: Solusi Baru',
                          ),
                        ],
                      )),
                    ]),
                  ]),
                  const SizedBox(height: 20),

                  // ── SECTION 2: Detail Artikel & Solusi ─────────────────
                  _SectionHeader(
                    number: '2',
                    title: 'Detail Artikel & Solusi',
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 16),
                  _FormCard(children: [
                    _fieldLabel('Judul Langkah'),
                    _textField(
                      controller: _judulLangkahCtrl,
                      hint: 'Contoh: Langkah Penyelamatan',
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Masalah'),
                    _textArea(
                      controller: _masalahCtrl,
                      hint: 'Deskripsikan masalah utama yang dihadapi petani...',
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Penyebab'),
                    _textArea(
                      controller: _penyebabCtrl,
                      hint: 'Apa penyebab dari masalah tersebut?',
                    ),
                    const SizedBox(height: 20),

                    // ── Langkah Solusi Dinamis ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fieldLabel('Solusi Langkah-demi-Langkah'),
                        Text(
                          '${_langkahControllers.length} langkah',
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_langkahControllers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nomor langkah
                            Container(
                              width: 28, height: 28,
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Input langkah
                            Expanded(
                              child: TextFormField(
                                controller: _langkahControllers[i],
                                minLines: 2,
                                maxLines: 4,
                                decoration: _inputDec(
                                  'Langkah ke-${i + 1}...',
                                ).copyWith(
                                  suffixIcon: _langkahControllers.length > 1
                                    ? IconButton(
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: Colors.redAccent, size: 18),
                                        onPressed: () => _removeLangkah(i),
                                      )
                                    : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Tombol + Tambah Langkah
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.6)),
                        foregroundColor: AppColors.primaryGreen,
                      ),
                      onPressed: _addLangkah,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('+ TAMBAH LANGKAH',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Tips Ahli'),
                    _textArea(
                      controller: _tipsAhliCtrl,
                      hint: 'Berikan tips tambahan dari pakar pertanian sorgum...',
                      minLines: 3,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── SECTION 3: Media Thumbnail ─────────────────────────
                  _SectionHeader(
                    number: '3',
                    title: 'Media Thumbnail',
                    color: const Color(0xFF6A1B9A),
                  ),
                  const SizedBox(height: 16),
                  _FormCard(children: [
                    _fieldLabel('Thumbnail Artikel'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickThumbnail,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _thumbnailBase64.isEmpty
                                ? const Color(0xFFDDDDDD)
                                : AppColors.primaryGreen,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _thumbnailBase64.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded,
                                      size: 48,
                                      color: AppColors.textLight.withOpacity(0.5)),
                                  const SizedBox(height: 10),
                                  const Text('KLIK UNTUK UPLOAD THUMBNAIL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textLight,
                                        letterSpacing: 0.5,
                                      )),
                                  const SizedBox(height: 4),
                                  const Text('JPG / PNG — Disimpan ke SQLite',
                                      style: TextStyle(
                                          fontSize: 10, color: AppColors.textLight)),
                                ],
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      base64Decode(_thumbnailBase64),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8, right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _thumbnailBase64 = ''),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8, right: 8,
                                    child: GestureDetector(
                                      onTap: _pickThumbnail,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit, color: Colors.white, size: 12),
                                            SizedBox(width: 4),
                                            Text('Ganti', style: TextStyle(color: Colors.white, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget Pendukung (lokal, hanya untuk form ini)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  final Color color;
  const _SectionHeader({required this.number, required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(number, style: const TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 10),
      Text(title, style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: color.withOpacity(0.3), thickness: 1)),
    ],
  );
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _BottomActionBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  const _BottomActionBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, -2))],
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF455A64),
              side: BorderSide.none,
            ),
            onPressed: isSaving ? null : onCancel,
            child: const Text('BATAL',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                    fontSize: 13, letterSpacing: 0.5)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(saveLabel, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
          ),
        ),
      ],
    ),
  );
}

// ── Helpers Input Decoration ──────────────────────────────────────────────────
Widget _fieldLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
);

InputDecoration _inputDec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
  filled: true,
  fillColor: const Color(0xFFF7F8FA),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
);

Widget _textField({
  required TextEditingController controller,
  required String hint,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: controller,
  decoration: _inputDec(hint),
  validator: validator,
);

Widget _textArea({
  required TextEditingController controller,
  required String hint,
  int minLines = 4,
}) => TextFormField(
  controller: controller,
  minLines: minLines,
  maxLines: minLines + 4,
  decoration: _inputDec(hint),
);

Widget _dropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) => DropdownButtonFormField<String>(
  value: value,
  decoration: _inputDec(''),
  isExpanded: true,
  items: items.map((k) =>
    DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
  onChanged: onChanged,
);
