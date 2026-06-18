import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/helpers/shared_prefs_helper.dart';

class SearchSettingsScreen extends StatefulWidget {
  const SearchSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SearchSettingsScreen> createState() => _SearchSettingsScreenState();
}

class _SearchSettingsScreenState extends State<SearchSettingsScreen> {
  bool _isSuggestionsOn = true;
  int _historyLimit = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final suggestionsOn = await SharedPrefsHelper.isSearchSuggestionsOn();
    final limit = await SharedPrefsHelper.getSearchHistoryLimit();
    setState(() {
      _isSuggestionsOn = suggestionsOn;
      _historyLimit = limit;
      _isLoading = false;
    });
  }

  Future<void> _toggleSuggestions(bool value) async {
    setState(() => _isSuggestionsOn = true);
    await SharedPrefsHelper.setSearchSuggestionsOn(true);
    _showFeedbackSnackBar('Saran pencarian ditetapkan selalu aktif');
  }

  Future<void> _changeLimit(int? value) async {
    if (value == null) return;
    setState(() => _historyLimit = value);
    await SharedPrefsHelper.setSearchHistoryLimit(value);
    _showFeedbackSnackBar('Batas riwayat pencarian diubah menjadi $value item');
  }

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.textCharcoal,
      ),
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
            'Pengaturan Pencarian',
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
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      children: [
                        // Switch Saran Pencarian
                        _buildSwitchTile(
                          title: 'Saran Pencarian',
                          subtitle: 'Rekomendasi riwayat pencarian selalu aktif.',
                          value: _isSuggestionsOn,
                          onChanged: _toggleSuggestions,
                        ),
                        const SizedBox(height: 12),

                        // Batas Maksimal Riwayat Pencarian
                        _buildDropdownTile(
                          title: 'Batas Riwayat Pencarian',
                          subtitle: 'Jumlah maksimal riwayat pencarian yang disimpan.',
                          value: _historyLimit,
                          items: const [5, 10, 15, 20],
                          onChanged: _changeLimit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardLightGrey, width: 1),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppColors.primaryGreen,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: AppColors.cardLightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardLightGrey, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textCharcoal),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardLightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textCharcoal),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                items: items.map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val item'),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
