import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/eventsPage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/model/event.dart';
import '../database/model/poi.dart';
import '../text_styles/TextStyleGillMT.dart';



class LocationSinglePage extends StatelessWidget {
  final POI location;

  const LocationSinglePage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(
            color: Colors.black,
            size: 28,
          ),
          titleTextStyle: const TextStyle(
            fontFamily: 'GillSansMT',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          title: Text(location.name),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                // do something
              },
            ),
          ],
        ),
        body: SingleChildScrollView(

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                child: DetailsSection(location: location)
              ),
              Divider(thickness: 2, color: Colors.black, indent: 6, endIndent: 6,),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: EventsSection(location: location)
              ),
              Divider(thickness: 2, color: Colors.black, indent: 6, endIndent: 6,),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: PhotosSection(location: location)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsSection extends StatelessWidget {
  final POI location;

  const DetailsSection({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    String priceText = (location.price != null) ? (location.price! > 0 ? "${location.price!} €" : "Free") : '???';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: GillMT.title(20),),
          const Divider(color: Colors.black87, thickness: 0.2),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: Melhorar as tags
                    Text("Tags:  ${location.tags}" , style: GillMT.normal(18),),
                    Text("• City:  ${location.cityName ?? '???'}", style: GillMT.normal(18).copyWith(height: 1.3),),
                    Text("• Address:  ${location.address ?? '???'}" , style: GillMT.normal(18).copyWith(height: 1.3),),
                    Text("• Ticket price:  $priceText" , style: GillMT.normal(18).copyWith(height: 1.3),),
                    Linkify(
                      onOpen: (link) async {
                        Uri uri = Uri.parse(link.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: "• Website:  ${location.website ?? '???'}",
                      style: GillMT.normal(18).copyWith(height: 1.3),
                      linkStyle: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              Icon(Icons.star_border_rounded, color: Colors.black,),
                              // TODO: Replace with reviews average and count
                              Flexible(
                                child: Text("4.5 (543)" , style: GillMT.normal(15).copyWith(color: Colors.black),)
                              )

                            ],
                          ),
                        ),
                      ),
                    ),

                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: EdgeInsets.all(2)),
                          child: Text("Write Review" , style: GillMT.normal(15).copyWith(color: Colors.black),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10),
          Text(location.description ?? '(No description available)' , style: GillMT.normal(18).copyWith(height: 1.3), textAlign: TextAlign.justify,),
        ],
      )
    );
  }

}

class EventsSection extends StatefulWidget {
  final POI location;

  EventsSection({super.key, required this.location});

  @override
  State<StatefulWidget> createState() => _EventsSectionState();

}

class _EventsSectionState extends State<EventsSection> {
  final PageController _pageController = PageController();
  int locationsPerPage = 2;
  int _currentPage = 0;
  int pageCount = 0;

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

  Widget buildEventGrid(List<Event> events) {
    return Expanded(
        child: PageView.builder(
          controller: _pageController,
          itemCount: pageCount,
          itemBuilder: (context, pageIndex) {
            int startIndex = pageIndex * locationsPerPage;
            int endIndex = startIndex + locationsPerPage;
            List<Event> pageEvents = events.sublist(startIndex, endIndex > events.length ? events.length : endIndex);
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
              ),
              itemCount: pageEvents.length,
              itemBuilder: (context, index) {
                return EventGridItem(
                  event: pageEvents[index],
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
                );
              },
            );
          },
        ),
    );
  }



  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("What is happening here ?", style: GillMT.title(20),),
              SizedBox(height: 10),
              FutureBuilder(
                  future: NexaGuideDB().fetchEventsByPOI(widget.location.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      pageCount = (snapshot.data!.length / locationsPerPage).ceil();
                      if (snapshot.data!.isEmpty) {
                        return Text('There are no events here at the moment.', style: GillMT.normal(15),);
                      }
                      else {
                        return SizedBox(
                          height: 200,
                          child: Column(
                            children: [
                              buildEventGrid(snapshot.data!),
                              _buildPageIndicator()
                            ],
                          ),
                        );
                      }
                    }
                    else {
                      return const CircularProgressIndicator(color: Colors.orange);
                    }
                  }
              ),
            ],
          ),
    );
  }

}


class PhotosSection extends StatelessWidget {
  final POI location;

  const PhotosSection({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Photos", style: GillMT.title(20),),
          SizedBox(height: 10),
          Text('Photos will appear here', style: GillMT.normal(16),)
        ],
      ),
    );
  }
}
