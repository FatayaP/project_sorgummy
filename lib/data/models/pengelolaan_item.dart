class PengelolaanItem {
  final int? id;
  final String activity;
  final String date;
  final String notes;

  PengelolaanItem({
    this.id,
    required this.activity,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity': activity,
      'date': date,
      'notes': notes,
    };
  }

  factory PengelolaanItem.fromMap(Map<String, dynamic> map) {
    return PengelolaanItem(
      id: map['id'] != null ? map['id'] as int : null,
      activity: map['activity'] as String,
      date: map['date'] as String,
      notes: map['notes'] as String,
    );
  }
}