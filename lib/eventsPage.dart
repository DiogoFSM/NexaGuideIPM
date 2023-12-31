import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';
import 'database/model/event.dart';
import 'database/nexaguide_db.dart';
import 'collectionsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexaguide_ipm/Review/Review.dart';


class eventsPage extends StatefulWidget {
  final List<Event> events;
  final int? initialEventId;

  eventsPage({Key? key, required this.events, this.initialEventId}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<eventsPage> {
  late final List<Event> events;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _addReview(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(placeName: event.name, userName: username, userPhotoUrl: "null"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    events = widget.events;

    void _showEventDetailsDialog(BuildContext context, int eventId) {
      final event = events.firstWhere((event) => event.id == eventId);
      final DateFormat format = DateFormat('dd/MM/yyyy');

      if (event != null) {    String dateStart = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateStart).toLocal());
      String dateEnd = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateEnd).toLocal());
      String dateText = dateStart == dateEnd ? dateStart : '$dateStart - $dateEnd';
      String priceText = (event.price != null && event.price! > 0) ? "${event.price!} €" : "Free";

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
                        fontFamily: 'GillSansMT'
                    ),
                  ),
                  const Divider(
                    color: Colors.black26,
                    thickness: 2,
                  ),
                  Text('• Location:  ${event.location}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                  // TODO: Talvez meter o sitio (POI) onde o evento decorre??
                  SizedBox(height: 8),
                  Text('• Time:  ${event.startTime} - ${event.endTime}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                  SizedBox(height: 8),
                  //Text('Data: ${event.dateStart} - ${event.dateEnd}'),
                  Text('• Date:  $dateText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                  SizedBox(height: 8),
                  Text('• Price:  $priceText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                  SizedBox(height: 8),
                  Text('• Website:  ${event.website}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      // TODO: Trocar para iconButton
                      Icon(Icons.pin_drop_rounded, color: Colors.orange, size: 36),
                      SizedBox(width: 15),
                      IconButton(
                        icon: Icon(Icons.bookmark_add_outlined, color: Colors.orange, size: 36),
                        onPressed: () {
                        },
                      ),
                      SizedBox(width: 15),
                      Icon(Icons.star_outline_rounded, color: Colors.orange, size: 36),
                      // Add more icons as needed
                    ],
                  ),
                  SizedBox(height: 8),
                  // TODO: Adicionar tags
                  Text('${event.description}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)), // Replace with actual description
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17, color: Colors.orange)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      }
    }


    if (widget.initialEventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEventDetailsDialog(context, widget.initialEventId!);
      });
    }



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
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Events...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)
                    // onChanged or onSubmitted for handling input
                  ),
                ),
              ),

              IconButton(
                icon: Icon(Icons.tune_rounded),
                iconSize: 28,
                onPressed: () {
                  showFiltersDialog(context);
                },
              ),

              IconButton(
                icon: Icon(Icons.menu_rounded),
                iconSize: 28,
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
                    Event currentEvent = pageEvents[index];
                    return EventGridItem(
                      event: currentEvent,
                      onBookmark: (eventId, collectionId) {
                        NexaGuideDB().addEventToCollection(eventId, collectionId).then((_) {
                          // Handle success, maybe show a snackbar message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Event added to collection')),
                          );
                        }).catchError((e) {
                          // Handle error, maybe show a snackbar message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add event to collection')),
                          );
                        });
                      },
                      onAddReview: () => _addReview(currentEvent),
                    );
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
              (index) => Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.orange : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int minPrice = 0;
  int maxPrice = 200;
  double selectedDistance = 0.0;
  int minRating = 0;
  int maxRating = 5;

  void showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Temporary variables to hold slider values
        int tempMinPrice = minPrice;
        int tempMaxPrice = maxPrice;
        double tempSelectedDistance = selectedDistance;
        int tempMinRating = minRating;
        int tempMaxRating = maxRating;
        List<String> tempSelectedTags = []; // Temporary list for selected tags

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filters'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Price range: ${tempMinPrice} - ${tempMaxPrice} €'),
                    RangeSlider(
                      values: RangeValues(tempMinPrice.toDouble(), tempMaxPrice.toDouble()),
                      min: 0,
                      max: 200,
                      //divisions: 40,
                      onChanged: (RangeValues values) {
                        setState(() {
                          tempMinPrice = values.start.round();
                          tempMaxPrice = values.end.round();
                        });
                      },
                    ),
                    Text('Rating: $tempMinRating - $tempMaxRating'),
                    RangeSlider(
                      values: RangeValues(tempMinRating.toDouble(), tempMaxRating.toDouble()),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      onChanged: (RangeValues values) {
                        setState(() {
                          tempMinRating = values.start.round();
                          tempMaxRating = values.end.round();
                        });
                      },
                    ),
                    Text('Maximum Distance: ${tempSelectedDistance.toStringAsFixed(1)} km'),
                    Slider(
                      value: tempSelectedDistance,
                      onChanged: (newValue) {
                        setState(() {
                          tempSelectedDistance = newValue;
                        });
                      },
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: "${tempSelectedDistance.toStringAsFixed(1)} km",
                    ),
                    Text('Tags:', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                    Wrap(
                      spacing: 8.0,
                      children: [
                        "Music", "Theater", "Sports", "Art", "For Kids",
                        "Open Space", "Outdoor", "Most Popular",
                        "Best Rated", "Adventure"
                      ].map((String tag) {
                        return FilterChip(
                          label: Text(tag),
                          selected: tempSelectedTags.contains(tag),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                tempSelectedTags.add(tag);
                              } else {
                                tempSelectedTags.removeWhere((String name) => name == tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            actions: <Widget>[
              /*
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
               */

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Apply', style: GillMT.normal(18)),
              ),
              ],
            );
          },
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
  final DateFormat format = DateFormat('dd/MM/yyyy');
  final Event event;
  final Function(int eventId, int collectionId) onBookmark;
  final VoidCallback onAddReview;  // New callback for review

  EventGridItem({required this.event, required this.onBookmark, required this.onAddReview});

  void _showEventDetailsDialog(BuildContext context) {
    String dateStart = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateStart).toLocal());
    String dateEnd = format.format(DateTime.fromMillisecondsSinceEpoch(event.dateEnd).toLocal());
    String dateText = dateStart == dateEnd ? dateStart : '$dateStart - $dateEnd';
    String priceText = (event.price != null && event.price! > 0) ? "${event.price!} €" : "Free";

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
                    fontFamily: 'GillSansMT'
                  ),
                ),
                const Divider(
                  color: Colors.black26,
                  thickness: 2,
                ),
                Text('• Location:  ${event.location}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                // TODO: Talvez meter o sitio (POI) onde o evento decorre??
                SizedBox(height: 8),
                Text('• Time:  ${event.startTime} - ${event.endTime}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                //Text('Data: ${event.dateStart} - ${event.dateEnd}'),
                Text('• Date:  $dateText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Text('• Price:  $priceText', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Text('• Website:  ${event.website}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    // TODO: Trocar para iconButton
                    Icon(Icons.pin_drop_rounded, color: Colors.orange, size: 36),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.bookmark_add_outlined, color: Colors.orange, size: 36),
                      onPressed: () async {
                        // Open the collections page and await the selected collection
                        final selectedCollectionId = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionsPage(selectMode: true),
                          ),
                        );
                        // If a collection was selected, call the callback to add the event to the collection
                        if (selectedCollectionId != null) {
                          onBookmark(event.id, selectedCollectionId);
                        }
                      },
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: Icon(Icons.star_outline_rounded, color: Colors.orange, size: 36),
                      onPressed: onAddReview, // Call the provided callback function
                    ),                // Add more icons as needed
                  ],
                ),
                SizedBox(height: 8),
                // TODO: Adicionar tags
                Text('${event.description}', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17)), // Replace with actual description
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(fontFamily: 'GillSansMT', fontSize: 17, color: Colors.orange)),
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
    String priceText = (event.price != null && event.price! > 0) ? "${event.price!} €" : "Free";

    return Container(
      margin: const EdgeInsets.all(4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GillSansMT',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Divider(
                color: Colors.black26,
                thickness: 2,
              ),

              //SizedBox(height: 4), // Give some space between text widgets
              Expanded(
                flex: 3,
                child: Text(
                  "${event.location}\n$dateText\nPrice:  $priceText",
                    style: TextStyle(fontFamily: 'GillSansMT', fontSize: 15)
                )
              ),

              //Text(event.location),
              //Text(dateText),
              //Spacer(), // Use Spacer to push the button to the bottom of the card
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.all(2)),
                      child: Text('View +', style: TextStyle(fontFamily: 'GillSansMT', color:Colors.black)),
                      onPressed: () => _showEventDetailsDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
