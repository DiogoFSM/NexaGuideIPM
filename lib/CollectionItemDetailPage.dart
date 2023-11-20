import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/database/model/event.dart';
import 'package:nexaguide_ipm/database/model/poi.dart';

class CollectionItemDetailPage extends StatefulWidget {
  final dynamic item;
  final int collectionId;
  final bool isBookmarked;

  CollectionItemDetailPage({
    Key? key,
    required this.item,
    required this.collectionId,
    this.isBookmarked = false,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<CollectionItemDetailPage> {
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.isBookmarked;
  }

  void toggleBookmark() async {
    final NexaGuideDB dbService = NexaGuideDB();

    setState(() {
      isBookmarked = !isBookmarked;
    });

    try {
      if (isBookmarked) {
        // Add to collection
        if (widget.item is Event) {
          await dbService.addEventToCollection(widget.item.id, widget.collectionId);
        } else if (widget.item is POI) {
          await dbService.addPOIToCollection(widget.item.id, widget.collectionId);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.item.name} added to collection')),
        );
      } else {
        // Remove from collection
        if (widget.item is Event) {
          await dbService.deleteEventFromCollection(widget.item.id, widget.collectionId);
        } else if (widget.item is POI) {
          await dbService.deletePOIFromCollection(widget.item.id, widget.collectionId);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.item.name} removed from collection')),
        );
      }
    } catch (e) {
      // If there is an error, set the bookmark status back
      setState(() {
        isBookmarked = !isBookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update collection')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Add your details here
      ),
    );
  }
}
