import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/collectionsPage.dart';
import 'database/model/event.dart';
import 'database/nexaguide_db.dart';
import 'eventsPage.dart';
import 'login.dart';
import 'main.dart';

class MenuScreen extends StatelessWidget {
  final database = NexaGuideDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
              _navigateToMapPage(context);
                // Navigate to Maps screen or handle the action
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.map, size: 80), // Use the appropriate icon
                  Text('Maps'),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: InkWell(
              onTap: () {
                _navigateToEventsPage(context);
                // Navigate to Events screen or handle the action
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.event, size: 80), // Use the appropriate icon
                  Text('Events'),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: InkWell(
              onTap: () {
                _navigateToCollectionsPage(context);
                // Navigate to Collections screen or handle the action
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.collections, size: 80), // Use the appropriate icon
                  Text('Collections'),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: InkWell(
              onTap: () {
                // Navigate to Login screen or handle the action
                _navigateToLoginPage(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.login, size: 80), // Use the appropriate icon
                  Text('Login'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _navigateToEventsPage(BuildContext context) async {
    database.createEvent(name: "Nos Alive", poiID: 1, dateStart: 0, dateEnd: 200, location: "Algés", endTime: "04:00h", startTime: "18:00h", price: 45);
    List<Event> events = await database.fetchAllEvents();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => eventsPage(events: events)),
    );
  }
  void _navigateToCollectionsPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CollectionsPage()),
    );
  }
  void _navigateToLoginPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  void _navigateToMapPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>MyHomePage(title: 'Nexaguide')),
    );
  }
}
