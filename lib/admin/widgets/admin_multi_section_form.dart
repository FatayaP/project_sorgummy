import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sorgummi_ai/core/constants/colors.dart';

class AdminMultiSectionForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool isSaving;
  final ValueChanged<Map<String, dynamic>> onSave;
  final VoidCallback onCancel;

  const AdminMultiSectionForm({
    Key? key,
    this.initialData,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<AdminMultiSectionForm> createState() => _AdminMultiSectionFormState();
}

class _AdminMultiSectionFormState extends State<AdminMultiSectionForm> {
  final _formKey = GlobalKey<FormState>();

  // ── Section 1 ──────────────────────────────────────────────────────────────
  final _judulCtrl = TextEditingController();
  final _estimasiCtrl = TextEditingController();
  final _badgeCtrl = TextEditingController();
  String _selectedKategori = 'Stok Biji';
  String _selectedStatus = 'Active';

  static const List<String> _kategoriOptions = [
    'Stok Biji', 'Hasil Panen', 'Produk Olahan',
    'Pupuk & Pestisida', 'Peralatan', 'Umum',
  ];

  // ── Section 2 ──────────────────────────────────────────────────────────────
  final _judulLangkahCtrl = TextEditingController();
  final _masalahCtrl = TextEditingController();
  final _penyebabCtrl = TextEditingController();
  final _tipsAhliCtrl = TextEditingController();
  final List<TextEditingController> _langkahControllers = [];

  // ── Section 3 ──────────────────────────────────────────────────────────────
  String _thumbnailBase64 = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _populate();
  }

  void _populate() {
    final e = widget.initialData;
    if (e == null) {
      _langkahControllers.add(TextEditingController());
      return;
    }
    _judulCtrl.text = e['judul'] ?? '';
    _selectedKategori = _kategoriOptions.contains(e['kategori'])
        ? e['kategori']
        : _kategoriOptions.first;
    _selectedStatus = e['status'] ?? 'Active';
    _estimasiCtrl.text = e['estimasi_baca'] ?? '';
    _badgeCtrl.text = e['badge'] ?? '';
    _judulLangkahCtrl.text = e['judul_langkah'] ?? '';
    _masalahCtrl.text = e['masalah'] ?? '';
    _penyebabCtrl.text = e['penyebab'] ?? '';
    _tipsAhliCtrl.text = e['tips_ahli'] ?? '';
    _thumbnailBase64 = e['thumbnail'] ?? '';
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

  Future<void> _pickThumbnail() async {
    try {
      final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _thumbnailBase64 = base64Encode(bytes));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memilih gambar: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _addLangkah() =>
      setState(() => _langkahControllers.add(TextEditingController()));

  void _removeLangkah(int i) {
    if (_langkahControllers.length <= 1) return;
    setState(() {
      _langkahControllers[i].dispose();
      _langkahControllers.removeAt(i);
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final langkahList = _langkahControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    final now = DateTime.now();
    final tanggal =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final data = <String, dynamic>{
      if (widget.initialData != null) 'id': widget.initialData!['id'],
      'judul': _judulCtrl.text.trim(),
      'kategori': _selectedKategori,
      'status': _selectedStatus,
      'estimasi_baca': _estimasiCtrl.text.trim(),
      'badge': _badgeCtrl.text.trim(),
      'judul_langkah': _judulLangkahCtrl.text.trim(),
      'masalah': _masalahCtrl.text.trim(),
      'penyebab': _penyebabCtrl.text.trim(),
      'langkah_solusi': jsonEncode(langkahList),
      'tips_ahli': _tipsAhliCtrl.text.trim(),
      'konten': '${_masalahCtrl.text.trim()}\n\n${langkahList.join('\n')}',
      'thumbnail': _thumbnailBase64,
      'views': widget.initialData?['views'] ?? 0,
      'tanggal': widget.initialData?['tanggal'] ?? tanggal,
    };

    widget.onSave(data);
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF558B2F);
    final isEdit = widget.initialData != null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── SECTION 1 ─────────────────────────────────────────
                  _SectionHeader(
                      number: '1', title: 'Informasi Dasar', color: accentColor),
                  const SizedBox(height: 16),
                  _Card(children: [
                    _lbl('Judul Panduan / Produk *'),
                    _tf(
                        controller: _judulCtrl,
                        hint: 'Contoh: Cara Penyimpanan Biji Sorgum',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Judul wajib diisi'
                            : null),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Kategori *'),
                          const SizedBox(height: 6),
                          _dd(
                              value: _selectedKategori,
                              items: _kategoriOptions,
                              onChanged: (v) =>
                                  setState(() => _selectedKategori = v!)),
                        ],
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Status'),
                          const SizedBox(height: 6),
                          _dd(
                              value: _selectedStatus,
                              items: const ['Active', 'Draft'],
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!)),
                        ],
                      )),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _lbl('Estimasi Waktu'),
                            _tf(controller: _estimasiCtrl, hint: '5 Menit')
                          ])),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _lbl('Badge / Label'),
                            _tf(controller: _badgeCtrl, hint: 'Panduan Baru')
                          ])),
                    ]),
                  ]),
                  const SizedBox(height: 20),

                  // ── SECTION 2 ─────────────────────────────────────────
                  _SectionHeader(
                      number: '2',
                      title: 'Detail & Langkah Panduan',
                      color: const Color(0xFF1565C0)),
                  const SizedBox(height: 16),
                  _Card(children: [
                    _lbl('Judul Langkah'),
                    _tf(
                        controller: _judulLangkahCtrl,
                        hint: 'Contoh: Langkah Penyimpanan Optimal'),
                    const SizedBox(height: 16),
                    _lbl('Masalah'),
                    _ta(
                        controller: _masalahCtrl,
                        hint: 'Deskripsikan masalah yang sering dihadapi petani...'),
                    const SizedBox(height: 16),
                    _lbl('Penyebab'),
                    _ta(
                        controller: _penyebabCtrl,
                        hint: 'Apa penyebab dari masalah tersebut?'),
                    const SizedBox(height: 20),

                    // Langkah dinamis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _lbl('Langkah-Demi-Langkah'),
                        Text('${_langkahControllers.length} langkah',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                        _langkahControllers.length,
                        (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10),
                                    decoration: const BoxDecoration(
                                        color: accentColor,
                                        shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text('${i + 1}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                      child: TextFormField(
                                    controller: _langkahControllers[i],
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: _dec('Langkah ke-${i + 1}...')
                                        .copyWith(
                                      suffixIcon: _langkahControllers.length > 1
                                          ? IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.redAccent,
                                                  size: 18),
                                              onPressed: () =>
                                                  _removeLangkah(i))
                                          : null,
                                    ),
                                  )),
                                ],
                              ),
                            )),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: accentColor.withOpacity(0.6)),
                        foregroundColor: accentColor,
                      ),
                      onPressed: _addLangkah,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('+ TAMBAH LANGKAH',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    _lbl('Tips Ahli / Catatan Tambahan'),
                    _ta(
                        controller: _tipsAhliCtrl,
                        hint: 'Tips dari pakar pertanian sorgum...',
                        min: 3),
                  ]),
                  const SizedBox(height: 20),

                  // ── SECTION 3 ─────────────────────────────────────────
                  _SectionHeader(
                      number: '3',
                      title: 'Media Thumbnail',
                      color: const Color(0xFF6A1B9A)),
                  const SizedBox(height: 16),
                  _Card(children: [
                    _lbl('Thumbnail Panduan'),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _pickThumbnail,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: accentColor.withOpacity(0.2),
                        highlightColor: accentColor.withOpacity(0.1),
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
                                  : accentColor,
                              width: 1.5,
                            ),
                          ),
                          child: _thumbnailBase64.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.add_photo_alternate_rounded,
                                          size: 48,
                                          color: AppColors.textLight
                                              .withOpacity(0.5)),
                                      const SizedBox(height: 10),
                                      const Text('KLIK UNTUK UPLOAD THUMBNAIL',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textLight,
                                              letterSpacing: 0.5)),
                                      const SizedBox(height: 4),
                                      const Text(
                                          'JPG / PNG — Disimpan ke SQLite',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textLight)),
                                    ])
                              : Stack(fit: StackFit.expand, children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                        base64Decode(_thumbnailBase64),
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _thumbnailBase64 = ''),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ]),
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
        _BottomBar(
          isSaving: widget.isSaving,
          onCancel: widget.onCancel,
          onSave: _handleSave,
          saveLabel: isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN PANDUAN',
          accentColor: accentColor,
        ),
      ],
    );
  }

  // ── Local widget helpers ──────────────────────────────────────────────────
  Widget _lbl(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textCharcoal)));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF558B2F), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.redAccent, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Colors.redAccent, width: 1.5)),
      );

  Widget _tf({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
          controller: controller,
          decoration: _dec(hint),
          validator: validator);

  Widget _ta({
    required TextEditingController controller,
    required String hint,
    int min = 4,
  }) =>
      TextFormField(
          controller: controller,
          minLines: min,
          maxLines: min + 4,
          decoration: _dec(hint));

  Widget _dd({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
          value: value,
          decoration: _dec(''),
          isExpanded: true,
          items: items
              .map((k) => DropdownMenuItem(
                  value: k,
                  child: Text(k, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged);
}

class _SectionHeader extends StatelessWidget {
  final String number, title;
  final Color color;
  const _SectionHeader(
      {required this.number, required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 28,
            height: 28,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 12),
        Expanded(
            child: Divider(color: color.withOpacity(0.3), thickness: 1)),
      ]);
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
}

class _BottomBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel, onSave;
  final String saveLabel;
  final Color accentColor;
  const _BottomBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2))
            ]),
        child: Row(children: [
          Expanded(
              child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF455A64),
                side: BorderSide.none),
            onPressed: isSaving ? null : onCancel,
            child: const Text('BATAL',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5)),
          )),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(saveLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5)),
              )),
        ]),
      );
}
