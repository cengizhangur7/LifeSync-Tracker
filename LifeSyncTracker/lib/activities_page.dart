import 'package:flutter/material.dart';
import 'package:lifesync_tracker/activities_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class Activity {
  String name;
  String description;
  DateTime date;
  IconData? icon;

  Activity(
      {required this.name,
      required this.description,
      required this.date,
      required this.icon});
}

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> activities = [];
  List<String> potentialActivities = [
    'Running',
    'Reading',
    'Meditation',
    'Coding',
    'Swimming',
    'Yoga',
    'Gym',
    'Dancing',
    'Singing',
    'Cooking',
    'Painting',
    'Drawing',
    'Writing',
    'Gardening',
    'Walking',
    'Cycling',
    'Hiking',
    'Gaming',
    'Watching TV',
    'Watching Movies',
    'Listening to Music',
    'Playing Music',
    'Playing Board Games',
    'Playing Video Games',
    'Playing Sports',
    "Don't smoke",
    "Starting to not drink",
    "Drank",
    'Skiing',
    'Snowboarding',
    'Skating',
    'Surfing',
  ];
  static const IconData downhill_skiing_sharp =
      IconData(0xe8fd, fontFamily: 'MaterialIcons');
  static const IconData snowboarding =
      IconData(0xe5cd, fontFamily: 'MaterialIcons');
  static const IconData skating = IconData(0xe8f6, fontFamily: 'MaterialIcons');
  static const IconData surfing = IconData(0xe8f5, fontFamily: 'MaterialIcons');
  final Map<String, IconData> activityIcons = {
    'Running': Icons.directions_run,
    'Reading': Icons.book,
    'Meditation': Icons.self_improvement,
    'Coding': Icons.code,
    'Swimming': Icons.pool,
    'Yoga': Icons.self_improvement,
    'Gym': Icons.fitness_center,
    'Dancing': Icons.directions_run,
    'Singing': Icons.music_note,
    'Cooking': Icons.restaurant,
    'Painting': Icons.brush,
    'Drawing': Icons.brush,
    'Writing': Icons.create,
    'Gardening': Icons.eco,
    'Walking': Icons.directions_walk,
    'Cycling': Icons.directions_bike,
    'Hiking': Icons.directions_walk,
    'Gaming': Icons.sports_esports,
    'Watching TV': Icons.tv,
    'Watching Movies': Icons.movie,
    'Listening to Music': Icons.headphones,
    'Playing Music': Icons.music_note,
    'Playing Board Games': Icons.games,
    'Playing Video Games': Icons.sports_esports,
    'Playing Sports': Icons.sports_basketball,
    "Don't smoke": Icons.smoking_rooms,
    "Starting to not drink": Icons.local_bar,
    "Drank": Icons.local_bar,
    'Skiing': downhill_skiing_sharp,
    'Snowboarding': snowboarding,
    'Skating': skating,
    'Surfing': surfing,
    // Add more activities and their corresponding icons here
  };

  String selectedActivity = '';
  String activityDescription = '';
  DateTime selectedDate = DateTime.now();

  void addActivity() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Activity'),
              content: Column(
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Activity'),
                    value:
                        selectedActivity.isNotEmpty ? selectedActivity : null,
                    items: potentialActivities
                        .map((activity) => DropdownMenuItem(
                              child: Text(activity),
                              value: activity,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedActivity = value!;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter description'),
                    onChanged: (value) {
                      setState(() {
                        activityDescription = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0), // Adjust this value as needed
                    child: ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                          "Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // This is the button color
                        onPrimary: Colors.white, // This is the text color
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetActivityForm();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    if (selectedActivity.isNotEmpty &&
                        activityDescription.isNotEmpty) {
                      final activitiesModel =
                          Provider.of<ActivitiesModel>(context, listen: false);
                      activitiesModel.addActivity(Activity(
                        name: selectedActivity,
                        description: activityDescription,
                        date: selectedDate,
                        icon: activityIcons[selectedActivity] ?? Icons.help,
                      ));
                      resetActivityForm();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void resetActivityForm() {
    selectedActivity = '';
    activityDescription = '';
    selectedDate = DateTime.now();
  }

  void editActivity(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Activity'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter description'),
          onChanged: (value) {
            final activitiesModel =
                Provider.of<ActivitiesModel>(context, listen: false);
            Activity activity = activitiesModel.activities[index];
            activity.description = value;
            activitiesModel.updateActivity(index, activity);
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void showOptions(BuildContext context, Activity activity, int index) {
    final activitiesModel =
        Provider.of<ActivitiesModel>(context, listen: false);
    final activities = activitiesModel.activities;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('${activities[index].name}'),
            leading: Icon(activities[index].icon),
          ),
          ListTile(
            title: Text('Description: ${activities[index].description}'),
          ),
          ListTile(
            title: Text(
                'Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(activities[index].date)}'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Description'),
            onTap: () {
              Navigator.of(context).pop();
              editActivity(index);
            },
          ),
          ListTile(
            leading: Icon(Icons.date_range),
            title: Text('Change Date'),
            onTap: () {
              Navigator.of(context).pop();
              selectDate(index);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Activity'),
            onTap: () {
              Navigator.of(context).pop();
              deleteActivity(index);
            },
          ),
        ],
      ),
    );
  }

  void deleteActivity(int index) {
    final activitiesModel =
        Provider.of<ActivitiesModel>(context, listen: false);
    activitiesModel.deleteActivity(index);
  }

  Future<void> selectDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Provider.of<ActivitiesModel>(context, listen: false)
          .activities[index]
          .date,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final activitiesModel =
          Provider.of<ActivitiesModel>(context, listen: false);
      Activity activity = activitiesModel.activities[index];
      activity.date = picked;
      activitiesModel.updateActivity(index, activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final activities = activitiesModel.activities;

    activities
        .sort((a, b) => a.date.compareTo(b.date)); // Sort activities by date

    // Group activities by date
    final activitiesByDate = groupBy(activities, (a) => a.date);

    // Determine the background image based on the theme
    final String bgImage = Theme.of(context).brightness == Brightness.dark
        ? "assets/images/background.jpg"
        : "assets/images/lightbackground.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImage), // Use the appropriate background image
            fit: BoxFit.fitWidth,
          ),
        ),
        child: ListView.builder(
          itemCount: activitiesByDate.keys.length,
          itemBuilder: (context, index) {
            final date = activitiesByDate.keys.elementAt(index);
            final dateActivities = activitiesByDate[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(date),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...dateActivities.map((activity) {
                  return ListTile(
                    leading:
                        activity.icon != null ? Icon(activity.icon!) : null,
                    title: Text(activity.name),
                    onTap: () =>
                        showOptions(context, activity as Activity, index),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addActivity,
        tooltip: 'Add Activity',
        child: Icon(Icons.add, color: Colors.red),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
