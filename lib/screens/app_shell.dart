import 'package:flutter/material.dart';
import '../services/notes_repository.dart';
import '../theme.dart';
import 'calls_screen.dart';
import 'home_screen.dart';
import 'leads_screen.dart';
import 'profile_screen.dart';
import 'recordings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _callsKey = GlobalKey<CallsScreenState>();

  @override
  void initState() {
    super.initState();
    // Load the signed-in business's saved call notes once the app is open.
    NotesRepository.instance.load();
  }

  late final _screens = [
    const HomeScreen(),
    CallsScreen(key: _callsKey),
    const LeadsScreen(),
    const RecordingsScreen(),
    const ProfileScreen(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.call_rounded, label: 'Calls'),
    (icon: Icons.flag_rounded, label: 'Leads'),
    (icon: Icons.folder_rounded, label: 'Recordings'),
    (icon: Icons.settings_rounded, label: 'Profile'),
  ];

  void goToTab(int index) => setState(() => _index = index);

  void goToCallsFiltered(String filter) {
    setState(() => _index = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _callsKey.currentState?.setFilterByValue(filter));
  }

  @override
  Widget build(BuildContext context) {
    return TabNavigator(
      goToTab: goToTab,
      goToCallsFiltered: goToCallsFiltered,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(bottom: false, child: IndexedStack(index: _index, children: _screens)),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.bg,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final active = i == _index;
                final item = _items[i];
                return GestureDetector(
                  onTap: () => goToTab(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 20, color: active ? AppColors.blueInk : AppColors.inkFaint),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active ? AppColors.blueInk : AppColors.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class TabNavigator extends InheritedWidget {
  const TabNavigator({super.key, required this.goToTab, required this.goToCallsFiltered, required super.child});

  final ValueChanged<int> goToTab;
  final ValueChanged<String> goToCallsFiltered;

  static TabNavigator? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigator>();
  }

  @override
  bool updateShouldNotify(TabNavigator oldWidget) => goToTab != oldWidget.goToTab;
}
