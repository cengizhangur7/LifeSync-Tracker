import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lifesync_tracker/activities_model.dart'; 
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:lifesync_tracker/activities_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Activity> getActivitiesForMonth(
      List<Activity> activities, DateTime date) {
    return activities
        .where((activity) =>
            activity.date.month == date.month &&
            activity.date.year == date.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final activitiesModel = Provider.of<ActivitiesModel>(context);
    final activities = activitiesModel.activities;

    return Column(
      children: [
        // Calendar Section
        Expanded(
          child: Center(
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; 
                });

                final activitiesOnSelectedDay = activities
                    .where((activity) => isSameDay(activity.date, selectedDay))
                    .toList();

                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: Text(
                        'Activities on ${DateFormat('yyyy-MM-dd').format(selectedDay)}'),
                    children: activitiesOnSelectedDay.map((activity) {
                      return ListTile(
                        leading: Icon(activity.icon),
                        title: Text('Activity Name: ${activity.name}'),
                        subtitle: Text(
                            'Description: ${activity.description}\nTime: ${DateFormat('kk:mm').format(activity.date)}'),
                      );
                    }).toList(),
                  ),
                );
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, date, event) {
                  return Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(
                          255, 25, 248, 0), // Change this to the color you want
                    ),
                  );
                },
              ),
              eventLoader: (day) {
                return activities
                    .where((activity) => isSameDay(activity.date, day))
                    .toList();
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Builder(
              builder: (context) {
                final activitiesForMonth =
                    getActivitiesForMonth(activities, _focusedDay);

                
                final activityCounts =
                    groupBy(activitiesForMonth, (a) => a.name).map(
                        (name, activities) =>
                            MapEntry(name, activities.length));

                
                final sortedActivities = activityCounts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedActivities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 4 / 2,
                  ),
                  itemBuilder: (context, index) {
                    final activity = sortedActivities[index];
                    return Wrap(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 234, 15, 15),
                            border: Border.all(color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(
                              '${activity.key}',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Done ${activity.value} times',
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
