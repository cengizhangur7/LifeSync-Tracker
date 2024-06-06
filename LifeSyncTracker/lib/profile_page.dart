import 'package:flutter/material.dart';
import 'package:lifesync_tracker/activities_model.dart';
import 'package:lifesync_tracker/activities_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final activities = activitiesModel.activities;
    activities.sort((a, b) => a.date.compareTo(b.date));
    int daysWithoutDrinking = calculateDaysWithoutDrinking(activities);
    Map<String, dynamic> longestStreakData = calculateLongestStreak(activities);

    int longestStreak = longestStreakData['streak'];
    String longestStreakActivity = longestStreakData['activity'];
    String favoriteActivity = calculateFavoriteActivity(activities);
    double savings = calculateSavings(activities);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.red,
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'Building Habits'),
              Tab(text: 'Health'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      'Longest Streak: $longestStreak days ($longestStreakActivity)',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Favorite Activity: $favoriteActivity',
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Savings from not smoking: $savings TL',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  if (daysWithoutDrinking > 0)
                    Text(
                        'Not drinking king: Sober for $daysWithoutDrinking days',
                        style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> calculateLongestStreak(List<Activity> activities) {
    if (activities.isEmpty) {
      return {'streak': 0, 'activity': 'No activities yet. Start adding some!'};
    }

    int longestStreak = 0;
    int currentStreak = 0;
    String longestStreakActivity = activities[0].name;

    for (int i = 1; i < activities.length; i++) {
      if (activities[i].date.difference(activities[i - 1].date).inDays == 1 &&
          activities[i].name == activities[i - 1].name) {
        // If the current activity is one day after the previous activity and the activity is the same, increment the current streak
        currentStreak++;
      } else {
        // If the current activity is not on the same day as the previous activity or the activity is different, reset the current streak
        currentStreak = 1;
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        longestStreakActivity = activities[i].name;
      }
    }

    return {'streak': longestStreak + 1, 'activity': longestStreakActivity};
  }

  String calculateFavoriteActivity(List<Activity> activities) {
    if (activities.isEmpty) {
      return 'No activities yet. Start adding some!';
    }

    // Create a map to count the occurrences of each activity
    Map<String, int> countMap = {};

    for (Activity activity in activities) {
      if (countMap.containsKey(activity.name)) {
        countMap[activity.name] = countMap[activity.name]! + 1;
      } else {
        countMap[activity.name] = 1;
      }
    }

    // Find the activity with the most occurrences
    String favoriteActivity = countMap.keys.first;
    int maxCount = countMap[favoriteActivity]!;

    countMap.forEach((activity, count) {
      if (count > maxCount) {
        favoriteActivity = activity;
        maxCount = count;
      }
    });

    return favoriteActivity;
  }

  double calculateSavings(List<Activity> activities) {
    const double packCost = 55.0; // Cost of a pack of cigarettes
    double savings = 0.0;

    for (Activity activity in activities) {
      if (activity.name == "Don't smoke") {
        savings += packCost;
      }
    }

    return savings;
  }
}

int calculateDaysWithoutDrinking(List<Activity> activities) {
  DateTime? startNotDrinkingDate;
  for (Activity activity in activities) {
    if (activity.name == "Starting to not drink") {
      startNotDrinkingDate = activity.date;
    } else if (activity.name == "Drank") {
      startNotDrinkingDate = null;
    }
  }

  if (startNotDrinkingDate != null) {
    return DateTime.now().difference(startNotDrinkingDate).inDays;
  } else {
    return -1;
  }
}
