import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:nexaguide_ipm/Review/Review.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/eventsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/model/event.dart';
import '../database/model/poi.dart';
import 'package:nexaguide_ipm/collectionsPage.dart';
import '../text_styles/TextStyleGillMT.dart';



class LocationSinglePage extends StatelessWidget {
  final POI location;
  const LocationSinglePage({super.key, required this.location});

  Future<void> _addToCollection(BuildContext context, int poiId) async {
    final selectedCollectionId = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionsPage(selectMode: true),
      ),
    );
    if (selectedCollectionId != null) {
      try {
        await NexaGuideDB().addPOIToCollection(poiId, selectedCollectionId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location added to collection')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add location to collection')),
        );
      }
    }
  }
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
              icon: Icon(Icons.map_outlined),
              onPressed: () {
                // do something
              },
            ),

            IconButton(
              icon: Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                _addToCollection(context, location.id);
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
              const Divider(thickness: 2, color: Colors.black, indent: 6, endIndent: 6,),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: EventsSection(location: location)
              ),
              const Divider(thickness: 2, color: Colors.black, indent: 6, endIndent: 6,),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: PhotosSection()
              ),

              SizedBox(height:10),
              const Divider(color: Colors.black87, thickness: 0.2),
              Text("POI ID: ${location.id}", style: GillMT.lighter(16),),
              const Divider(color: Colors.black87, thickness: 0.2),
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
    //String priceText = (location.price != null && location.price! >= 0) ? (location.price! == 0 ? "Free" : "${location.price!} €") : '???';
    String priceText = (location.price != null && location.price! >= 0) ? location.price!.toString() : "Free";

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
                    // TODO: Melhorar a parte das tags
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
                              Flexible(
                                child: Text("${location.avgRating} (${location.reviewCount})" , style: GillMT.normal(15).copyWith(color: Colors.black),)
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
                            _addReview(context);
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
  Future<void> _addReview(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(placeName: location.name, userName: username, userPhotoUrl: "null"),
        ),
      );
    } else {
      // Show a SnackBar if not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not logged in'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

  Future<void> addReview(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      // Close the popup dialog first
      Navigator.pop(context);

      // Then navigate to the review page
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  onAddReview: () => addReview(pageEvents[index]),
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

class PhotosSection extends StatefulWidget {
  const PhotosSection({super.key});

  @override
  State<StatefulWidget> createState() => _PhotosSectionState();

}

class _PhotosSectionState extends State<PhotosSection> {
  final PageController _pageController = PageController();
  int photosPerPage = 2;
  int _currentPage = 0;
  int pageCount = 0;

  final imageURLs = [
    'https://www.fct.unl.pt/sites/default/files/imagens/noticias/2015/03/DSC_5142_Tratado.jpg',
    'https://arquivo.codingfest.fct.unl.pt/2016/sites/www.codingfest.fct.unl.pt/files/imagens/fctnova.jpeg',
    'https://www.fct.unl.pt/sites/default/files/imagecache/l740/imagens/noticias/2021/02/campusfct.png',
  ];

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget buildPhotoGrid(List<String> photos) {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          int startIndex = pageIndex * photosPerPage;
          int endIndex = startIndex + photosPerPage;
          List<String> pagePhotos = photos.sublist(startIndex, endIndex > photos.length ? photos.length : endIndex);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: pagePhotos.length,
            itemBuilder: (context, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.orange,
                  onTap: () {
                    SwipeImageGallery(
                      context: context,
                      itemBuilder: (context, index) {
                        return Image.network(imageURLs[index]);
                      },
                      itemCount: imageURLs.length,
                      initialIndex: startIndex+index,
                    ).show();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Image.network(
                        pagePhotos[index],
                        width:180,
                        fit: BoxFit.cover
                    ),
                  ),
                ),
              );
            },
          );
        },
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

  @override
  Widget build(BuildContext context) {
    pageCount = (imageURLs.length / photosPerPage).ceil();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Photos", style: GillMT.title(20),),
          SizedBox(height: 10),
          //Text('Photos will appear here', style: GillMT.normal(16),),
          SizedBox(
            height: 220,
            child: Column(
              children: [
                buildPhotoGrid(imageURLs),
                _buildPageIndicator()
              ],
            ),
          ),
        ],
      ),
    );
  }

}
