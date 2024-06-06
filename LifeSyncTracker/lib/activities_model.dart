import 'package:flutter/foundation.dart';
import 'activities_page.dart';

class ActivitiesModel extends ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void updateActivity(int index, Activity activity) {
    _activities[index] = activity;
    notifyListeners();
  }

  void deleteActivity(int index) {
    _activities.removeAt(index);
    notifyListeners();
  }
}
