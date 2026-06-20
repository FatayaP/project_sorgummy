import 'package:flutter/material.dart';
import 'package:sorgummi_ai/core/constants/colors.dart';
import 'package:sorgummi_ai/data/helpers/database_helper.dart';
import 'package:sorgummi_ai/admin/widgets/admin_multi_section_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Halaman Form Kelola Pengelolaan (Full-Screen — bebas overflow)
// ─────────────────────────────────────────────────────────────────────────────
class PengelolaanFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const PengelolaanFormPage({Key? key, this.existing}) : super(key: key);

  @override
  State<PengelolaanFormPage> createState() => _PengelolaanFormPageState();
}

class _PengelolaanFormPageState extends State<PengelolaanFormPage> {
  bool _isSaving = false;

  Future<void> _save(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);

    try {
      if (widget.existing != null) {
        await DatabaseHelper.instance.updatePengelolaanAdmin(data);
      } else {
        await DatabaseHelper.instance.insertPengelolaanAdmin(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Panduan Pengelolaan' : 'Tambah Panduan Baru',
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AdminMultiSectionForm(
            initialData: widget.existing,
            isSaving: _isSaving,
            onSave: _save,
            onCancel: () => Navigator.pop(context, false),
          ),
        ),
      ),
    );
  }
}

