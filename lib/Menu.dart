import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/collectionsPage.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/initialize_poi.dart';
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
        title: Text('Menu', style: GillMT.title(22)),
      ),
      body: FutureBuilder(
        future: database.fetchAllEvents(), // Isto e so para forçar a inicialização da base de dados, precisava de mais tempo para arranjar uma forma melhor
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Event>? events = snapshot.data;
            if (events!.isEmpty) {
              InitializePOIandEvents.initPOI();
              InitializePOIandEvents.initEvents();
            }
          }

          return snapshot.hasData ?
          Column(
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
                label: 'Login/Logout',
                onTap: () => _navigateToLoginPage(context),
              ),
              /*
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  SharedPreferences? prefs = snapshot.data;
                  String? username = prefs?.getString('username');

                  return username != null ?
                    _buildMenuButton(
                      context,
                      iconData: Icons.logout,
                      label: 'Logout',
                      onTap: () => _navigateToLoginPage(context),
                    )
                  : _buildMenuButton(
                      context,
                      iconData: Icons.login,
                      label: 'Login',
                      onTap: () => _navigateToLoginPage(context),
                    );
                }
              )
               */

            ],
          )

              : const CircularProgressIndicator(color: Colors.orange);
        },
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
              Text(label, style: GillMT.normal(20)), // Text label for the button
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEventsPage(BuildContext context) async {
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
