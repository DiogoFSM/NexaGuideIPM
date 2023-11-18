import 'package:flutter/material.dart';
import 'eventDetailPage.dart';

class eventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<eventsPage> {
  final List<Event> events = List.generate(20, (index) => Event(index));
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
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
  final Event event;

  EventGridItem(this.event);

  void _showEventDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView( // To ensure the dialog is scrollable if content is too long
            child: ListBody(
              children: <Widget>[
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Morada: ${event.location}'),
                SizedBox(height: 8),
                Text('Horário: ${event.startTime} - ${event.endTime}'),
                SizedBox(height: 8),
                Text('Data: ${event.startDate} - ${event.endDate}'),
                SizedBox(height: 8),
                Text('Preço: ${event.price}'),
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
                Text('O melhor festival em Portugal bla bla bla...'), // Replace with actual description
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4), // Give some space between text widgets
            Text(event.location),
            Text('${event.startDate} - ${event.endDate}'),
            Spacer(), // Use Spacer to push the button to the bottom of the card
            ElevatedButton(
              child: Text('Ver+'),
              onPressed: () => _showEventDetailsDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for event data model
class Event {
  final int id;
  String get title => 'Event $id'; // Example title, replace with actual data
  String get location => 'Algés'; // Example location, replace with actual data
  String get startTime => '18:00h'; // Example start time, replace with actual data
  String get endTime => '04:00h'; // Example end time, replace with actual data
  String get endDate => '16 jul'; // Example end date, replace with actual data
  String get startDate => '12 jul'; // Example start date, replace with actual data
  String get price => '60€'; // Example price, replace with actual data

  Event(this.id);
}
