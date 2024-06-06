import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lifesync_tracker/activities_page.dart';
import 'package:provider/provider.dart';
import 'activities_model.dart';
import 'package:intl/intl.dart';
import 'package:lifesync_tracker/achievements_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Activities',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ActivitiesModel(),
          ),
        ],
        child: HomePage(),
      ),
    );
  }
}

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  Future<WeatherModel> getWeatherForDate(DateTime date) async {
    int forecastDays = date.difference(DateTime.now()).inDays;
    if (forecastDays < 0 || forecastDays > 16) {
      throw Exception('Can only fetch forecast for the next 16 days');
    }

    String url =
        'https://api.weatherbit.io/v2.0/forecast/daily?city=Eskisehir&key=3dd597eda78245ffa72ab25a275c222e';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      // Assuming responseData structure, adjust accordingly
      Map<String, dynamic> data = responseData['data'][forecastDays];

      return WeatherModel(
        data['weather']['description'],
        data['temp'],
        data['weather']['icon'],
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherWidget extends StatelessWidget {
  final String activityName;
  final DateTime date;
  final WeatherService weatherService;

  WeatherWidget(this.date, this.weatherService, this.activityName);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: weatherService.getWeatherForDate(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final description = snapshot.data?.description ?? 'N/A';
          final temperature = snapshot.data?.temperature ?? 0.0;
          final iconCode = snapshot.data?.iconCode;
          return Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Upcoming Activity: ${activityName}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                      style: TextStyle(fontSize: 16)),
                  Text('Weather: $description, $temperature°',
                      style: TextStyle(fontSize: 16)),
                  if (iconCode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(
                          'https://www.weatherbit.io/static/img/icons/$iconCode.png'),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class WeatherModel {
  final String description;
  final double temperature;
  final String iconCode;
  WeatherModel(this.description, this.temperature, this.iconCode);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _controller2 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  final List<String> outdoorActivities = [
    'Running',
    'Hiking',
    'Walking',
    'Gardening',
    'Cycling',
    'Playing sports',
    'Skiing',
    'Snowboarding',
    'Skating',
    'Surfing',
  ];

  @override
  Widget build(BuildContext context) {
    final weatherService = WeatherService('3dd597eda78245ffa72ab25a275c222e');
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final upcomingActivities = activitiesModel.activities
        .where((activity) => activity.date.isAfter(DateTime.now()))
        .toList();

    Activity? upcomingActivity;
    if (upcomingActivities.isNotEmpty &&
        upcomingActivities
            .any((activity) => outdoorActivities.contains(activity.name))) {
      upcomingActivity = upcomingActivities.reduce((closest, current) =>
          current.date.isBefore(closest.date) ? current : closest);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _controller1,
                    child: AspectRatio(
                      aspectRatio: 1.0, // Make the widget square
                      child: AchievementsWidget(),
                    ),
                  ),
                ),
                SizedBox(
                    width:
                        5.0), // Change height to width for horizontal spacing
                Expanded(
                  child: FadeTransition(
                    opacity: _controller2,
                    child: AspectRatio(
                      aspectRatio: 1.0, // Make the widget square
                      child: ActivitiesSummaryWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          if (upcomingActivity != null &&
              outdoorActivities.contains(upcomingActivity.name))
            WeatherWidget(
                upcomingActivity.date,
                weatherService,
                upcomingActivity
                    .name), // Pass the date of the last activity here
          if (upcomingActivity == null ||
              !outdoorActivities.contains(upcomingActivity.name))
            Text('No upcoming outdoor activities'),
        ],
      ),
    );
  }
}

class AchievementsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to AchievementsPage when widget is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AchievementsPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8.0),
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivitiesSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final activities = activitiesModel.activities;
    activities.sort((a, b) => a.date.compareTo(b.date));

    // Calculate average activities per day
    final dailyAverage = calculateDailyAverage(activities);

    return GestureDetector(
      onTap: () {
        // Show detailed statistics when widget is tapped
        _showDetailedStatistics(context, activities);
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 233, 243, 33),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width:
                    8.0), // Change SizedBox height to width for horizontal spacing
            Expanded(
              child: Text(
                '${dailyAverage.toStringAsFixed(2)} activities',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateDailyAverage(List<Activity> activities) {
    if (activities.isEmpty) {
      return 0.0;
    }

    // Calculate the average number of activities per day
    final activitiesByDate = groupBy(activities, (a) => a.date);
    final totalDays = activitiesByDate.keys.length;
    final totalActivities = activities.length;

    return totalActivities / totalDays;
  }

  void _showDetailedStatistics(
      BuildContext context, List<Activity> activities) {
    // Calculate weekly and monthly averages
    final weeklyAverage = calculateWeeklyAverage(activities);
    final monthlyAverage = calculateMonthlyAverage(activities);

    // Show a bottom sheet with detailed statistics
    // Show a dialog with detailed statistics
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.yellow,
            textTheme: TextTheme(
              bodyText1: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.white),
            ),
          ),
          child: AlertDialog(
            title: Center(
              child: Text('Detailed Statistics',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Average: ${weeklyAverage.toStringAsFixed(2)} activities',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                    'Monthly Average: ${monthlyAverage.toStringAsFixed(2)} activities',
                    style: TextStyle(fontSize: 18.0)),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close',
                    style: TextStyle(color: Colors.red, fontSize: 18.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double calculateWeeklyAverage(List<Activity> activities) {
    if (activities.isEmpty) {
      return 0.0;
    }

    // Calculate the average number of activities per week
    final activitiesByWeek = groupBy(activities, (a) => _getWeekOfYear(a.date));
    final totalWeeks = activitiesByWeek.keys.length;
    final totalActivities = activities.length;

    return totalActivities / totalWeeks;
  }

  double calculateMonthlyAverage(List<Activity> activities) {
    if (activities.isEmpty) {
      return 0.0;
    }

    // Calculate the average number of activities per month
    final activitiesByMonth =
        groupBy(activities, (a) => DateFormat('yyyy-MM').format(a.date));
    final totalMonths = activitiesByMonth.keys.length;
    final totalActivities = activities.length;

    return totalActivities / totalMonths;
  }

  int _getWeekOfYear(DateTime date) {
    // Helper function to get the week number of the year for a given date
    final daysInWeek = 7;
    final beginningOfYear = DateTime(date.year, 1, 1);
    final daysFromBeginning = date.difference(beginningOfYear).inDays;
    return (daysFromBeginning / daysInWeek).ceil();
  }
}
