class CallEntry {
  const CallEntry({
    required this.initials,
    required this.name,
    required this.number,
    required this.type,
    required this.time,
    required this.duration,
    this.recorded = false,
    this.day = 'Today',
    this.timestamp = 0,
  });

  final String initials;
  final String name;
  final String number;
  final String type; // incoming | outgoing | missed
  final String time;
  final String duration;
  final bool recorded;
  final String day;
  final int timestamp; // millisecondsSinceEpoch, 0 for mock/placeholder entries
}

class Recording {
  const Recording({
    required this.initials,
    required this.name,
    required this.number,
    required this.when,
    required this.durationLabel,
    required this.durationSeconds,
  });

  final String initials;
  final String name;
  final String number;
  final String when;
  final String durationLabel;
  final int durationSeconds;
}

const recordings = [
  Recording(
    initials: 'PS',
    name: 'Priya Sharma',
    number: '+91 98765 43210',
    when: '22 Jul, 10:24 AM',
    durationLabel: '4:12',
    durationSeconds: 252,
  ),
  Recording(
    initials: 'AM',
    name: 'Arjun Mehta',
    number: '+91 99887 66554',
    when: '21 Jul, 6:40 PM',
    durationLabel: '7:30',
    durationSeconds: 450,
  ),
  Recording(
    initials: 'SR',
    name: 'Sneha Reddy',
    number: '+91 77002 98123',
    when: '22 Jul, 8:47 AM',
    durationLabel: '5:50',
    durationSeconds: 350,
  ),
  Recording(
    initials: 'VS',
    name: 'Vikram Singh',
    number: '+91 90210 11223',
    when: '18 Jul, 9:10 AM',
    durationLabel: '3:05',
    durationSeconds: 185,
  ),
  Recording(
    initials: 'KN',
    name: 'Kavita Nair',
    number: '+91 91234 56780',
    when: '17 Jul, 2:20 PM',
    durationLabel: '2:44',
    durationSeconds: 164,
  ),
];
