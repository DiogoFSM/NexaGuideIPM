import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database/model/event.dart';
import 'database/nexaguide_db.dart';

class eventsPage extends StatefulWidget {
  final List<Event> events;

  eventsPage({Key? key, required this.events}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<eventsPage> {
  late final List<Event> events;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    events = widget.events;

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  int get pageCount => (events.length / 6).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  showFiltersDialog(context);
                },
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Events',
                      border: InputBorder.none,
                    ),
                    // onChanged or onSubmitted for handling input
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  // Handle profile action
                },
              ),
            ],
          ),
          actions: [],
        ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * 6;
                int endIndex = startIndex + 6;
                List<Event> pageEvents = events.sublist(startIndex, endIndex > events.length ? events.length : endIndex);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3, // Adjust the aspect ratio as needed
                  ),
                  itemCount: pageEvents.length,
                  itemBuilder: (context, index) {
                    return EventGridItem(pageEvents[index]);
                  },
                );
              },
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          pageCount,
              (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Text('Filters options go here'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class EventGridItem extends StatelessWidget {
  DateFormat format = DateFormat('dd/MM/yyyy');
  final Event event;

  EventGridItem(this.event);

  void _showEventDetailsDialog(BuildContext context) {
    String dateStart = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateStart).toLocal());
    String dateEnd = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateEnd).toLocal());
    String dateText = dateStart == dateEnd ? dateStart : '$dateStart - $dateEnd';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView( // To ensure the dialog is scrollable if content is too long
            child: ListBody(
              children: <Widget>[
                Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Address: ${event.location}'),
                SizedBox(height: 8),
                Text('Time: ${event.startTime} - ${event.endTime}'),
                SizedBox(height: 8),
                //Text('Data: ${event.dateStart} - ${event.dateEnd}'),
                Text('Date: $dateText'),
                SizedBox(height: 8),
                Text('Price: ${event.price}'),
                SizedBox(height: 8),
                Text('Website: ${event.website}'),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(Icons.location_on, color: Colors.blue),
                    Icon(Icons.favorite_border, color: Colors.blue),
                    Icon(Icons.star_border, color: Colors.blue),
                    // Add more icons as needed
                  ],
                ),
                SizedBox(height: 8),
                Text('${event.description}'), // Replace with actual description
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateStart = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateStart).toLocal());
    String dateEnd = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateEnd).toLocal());
    String dateText = dateStart == dateEnd ? dateStart : '$dateStart - $dateEnd';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4), // Give some space between text widgets
            Text(event.location),
            Text(dateText),
            Spacer(), // Use Spacer to push the button to the bottom of the card
            ElevatedButton(
              child: Text('View +'),
              onPressed: () => _showEventDetailsDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
