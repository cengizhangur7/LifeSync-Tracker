import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lifesync_tracker/activities_model.dart';
import 'package:lifesync_tracker/activities_page.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final activities = activitiesModel.activities;

    // Calculate achievements
    final achievements = calculateAchievements(activities);

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: achievements.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust the number of grid items per row
        ),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 234, 255, 0), // Set background color to grey
              border: Border.all(
                color: Color.fromARGB(255, 255, 255, 255), // Set border color
                width: 3, // Set border width
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(activities[index].icon,size: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    achievement.stars,
                    (index) => Icon(Icons.star, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Achievement> calculateAchievements(List<Activity> activities) {
    // Group activities by name and calculate the number of stars for each group
    final groupedActivities = groupBy(activities, (a) => a.name);
    return groupedActivities.entries.map((entry) {
      final timesDone = entry.value.length;
      final stars = (timesDone / 3)
          .clamp(1, 5)
          .round(); // One star for every 3 times the activity is done
      return Achievement(entry.key, stars);
    }).toList();
  }
}

class Achievement {
  final String activityName;
  final int stars;

  Achievement(this.activityName, this.stars);
}

