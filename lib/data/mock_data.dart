class CallEntry {
  const CallEntry({
    required this.initials,
    required this.name,
    required this.number,
    required this.type,
    required this.time,
    required this.duration,
    this.durationSeconds = 0,
    this.day = 'Today',
    this.timestamp = 0,
  });

  final String initials;
  final String name;
  final String number;
  final String type; // incoming | outgoing | missed
  final String time;
  final String duration;
  final int durationSeconds;
  final String day;
  final int timestamp; // millisecondsSinceEpoch, 0 for mock/placeholder entries
}
