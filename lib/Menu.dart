import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/collectionsPage.dart';
import 'database/model/event.dart';
import 'database/nexaguide_db.dart';
import 'eventsPage.dart';
import 'login.dart';
import 'main.dart';

class MenuScreen extends StatelessWidget {
  final NexaGuideDB database = NexaGuideDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Column(
        children: <Widget>[
          _buildMenuButton(
            context,
            iconData: Icons.map,
            label: 'Maps',
            onTap: () => _navigateToMapPage(context),
          ),
          Divider(height: 1),
          _buildMenuButton(
            context,
            iconData: Icons.event,
            label: 'Events',
            onTap: () => _navigateToEventsPage(context),
          ),
          Divider(height: 1),
          _buildMenuButton(
            context,
            iconData: Icons.collections,
            label: 'Collections',
            onTap: () => _navigateToCollectionsPage(context),
          ),
          Divider(height: 1),
          _buildMenuButton(
            context,
            iconData: Icons.login,
            label: 'Login',
            onTap: () => _navigateToLoginPage(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData iconData, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container( // Use Container to ensure it fills the area
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center, // Center the column inside the container
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use min to wrap content in the column
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 80), // Icon for the button
              Text(label), // Text label for the button
            ],
          ),
        ),
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
      MaterialPageRoute(builder: (context) =>MyHomePage()),
    );
  }
}
