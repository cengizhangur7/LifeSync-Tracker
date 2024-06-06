import 'package:flutter/material.dart';
import 'package:lifesync_tracker/activities_model.dart';
import 'package:provider/provider.dart';
import 'activities_page.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifesync_tracker/profile_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ActivitiesModel()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Goal Prizes',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: GoalPrizesHomePage(),
    );
  }
}

class GoalPrizesHomePage extends StatefulWidget {
  @override
  _GoalPrizesHomePageState createState() => _GoalPrizesHomePageState();
}

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? prefs;
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _darkTheme = false;
    _loadFromPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = prefs!.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    prefs!.setBool(key, _darkTheme);
  }
}

class _GoalPrizesHomePageState extends State<GoalPrizesHomePage> {
  int _currentIndex = 1; // Home is the default page
  PageController _pageController = PageController();

  final List<Widget> _pages = [
    ActivitiesPage(),
    HomePage(),
    CalendarPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('LifeSync Tracker', style: TextStyle(color: const Color.fromARGB(255, 159, 0, 0), fontWeight: FontWeight.bold, fontFamily: AutofillHints.nickname)),
        centerTitle: true,
        actions: <Widget>[
          Switch(
            value: themeNotifier.darkTheme,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: [
          ..._pages,
          ProfilePage(), // Add this line
        ],
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new, color: Colors.red),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.amber), // Beige color
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: Colors.red),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.red),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
