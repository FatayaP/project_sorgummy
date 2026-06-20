import 'package:flutter/material.dart';
import 'package:sorgummi_ai/core/constants/colors.dart';
import 'package:sorgummi_ai/data/helpers/database_helper.dart';
import 'package:sorgummi_ai/admin/pengelolaan_form_page.dart';
import 'package:sorgummi_ai/admin/widgets/sorgum_status_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Kelola Pengelolaan — Admin CRUD (table_pengelolaan)
// ─────────────────────────────────────────────────────────────────────────────
class SorgumManagementScreen extends StatefulWidget {
  const SorgumManagementScreen({Key? key}) : super(key: key);

  @override
  State<SorgumManagementScreen> createState() => _SorgumManagementScreenState();
}

class _SorgumManagementScreenState extends State<SorgumManagementScreen> {
  late Future<List<Map<String, dynamic>>> _futureData;
  String _searchQuery = '';

  static const List<String> _kategoriOptions = [
    'Stok Biji',
    'Hasil Panen',
    'Produk Olahan',
    'Pupuk & Pestisida',
    'Peralatan',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureData = DatabaseHelper.instance.queryAllPengelolaanAdmin();
    });
  }

  // Navigasi ke halaman form (full-screen — bebas overflow)
  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PengelolaanFormPage(existing: existing),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDelete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Panduan?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text('Panduan "${row['judul']}" akan dihapus permanen dari database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: AppColors.textLight))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseHelper.instance.deletePengelolaanAdmin(row['id'] as int);
    _refresh();
    _showSnack('Panduan berhasil dihapus');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF558B2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(child: _SearchBar(onChanged: (q) => setState(() => _searchQuery = q))),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF558B2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Panduan', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabel
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureData,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF558B2F)));
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final all = snap.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? all
                    : all.where((r) =>
                        r['judul'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        r['kategori'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                    message: _searchQuery.isEmpty
                        ? 'Belum ada panduan pengelolaan.\nTekan "+ Tambah Panduan" untuk mulai.'
                        : 'Tidak ada hasil untuk "$_searchQuery".',
                    icon: Icons.agriculture_outlined,
                  );
                }

                return _PengelolaanDataTable(
                  rows: filtered,
                  onEdit: (r) => _openForm(existing: r),
                  onDelete: _confirmDelete,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    title: const Text('Kelola Stok & Pengelolaan',
        style: TextStyle(color: AppColors.textCharcoal, fontSize: 17, fontWeight: FontWeight.bold)),
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textCharcoal),
      onPressed: () => Navigator.pop(context),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: const Color(0xFFEEEEEE)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Tabel Data Pengelolaan
// ─────────────────────────────────────────────────────────────────────────────
class _PengelolaanDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  const _PengelolaanDataTable({required this.rows, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F8FA)),
              headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5),
              dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.textCharcoal),
              columnSpacing: 20,
              horizontalMargin: 20,
              dividerThickness: 0.8,
              columns: const [
                DataColumn(label: Text('NO')),
                DataColumn(label: Text('JUDUL PANDUAN')),
                DataColumn(label: Text('KATEGORI')),
                DataColumn(label: Text('TANGGAL')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('AKSI')),
              ],
              rows: rows.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('${i + 1}', style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold))),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(r['judul'] ?? '', overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                    ),
                    DataCell(_PengelolaanBadge(r['kategori'] ?? '')),
                    DataCell(Text(r['tanggal'] ?? '-', style: const TextStyle(color: AppColors.textLight, fontSize: 12))),
                    DataCell(SorgumStatusBadge(status: r['status'] ?? 'Aktif')),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(icon: Icons.edit_rounded, color: const Color(0xFF1565C0), tooltip: 'Edit', onTap: () => onEdit(r)),
                        const SizedBox(width: 6),
                        _ActionButton(icon: Icons.delete_outline_rounded, color: Colors.redAccent, tooltip: 'Hapus', onTap: () => onDelete(r)),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PengelolaanBadge extends StatelessWidget {
  final String label;
  const _PengelolaanBadge(this.label);

  Color get _color {
    switch (label.toLowerCase()) {
      case 'stok biji':        return const Color(0xFF558B2F);
      case 'hasil panen':      return const Color(0xFF2E7D32);
      case 'produk olahan':    return const Color(0xFF6A1B9A);
      case 'pupuk & pestisida':return const Color(0xFFE65100);
      case 'peralatan':        return const Color(0xFF1565C0);
      default:                 return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

// ── Shared widgets (duplikasi kecil agar tiap file mandiri) ──────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: 'Cari judul atau kategori...',
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: AppColors.textLight.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.6)),
      ]),
    ),
  );
}

Widget _buildLabel(String text) => Text(text,
  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textCharcoal));

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
  filled: true,
  fillColor: const Color(0xFFF7F8FA),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF558B2F), width: 1.5),
  ),
);
