import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';
import 'CollectionDetailPage.dart';

class CollectionsPage extends StatefulWidget {
  final bool selectMode; // Indicates if the page is opened for selection of a collection

  CollectionsPage({Key? key, this.selectMode = false}) : super(key: key);

  @override
  _CollectionsPageState createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  List<Collection> collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final fetchedCollections = await NexaGuideDB().fetchAllCollections();
    setState(() {
      collections = fetchedCollections;
    });
  }

  void _showCreateCollectionDialog() {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create a new collection', style: GillMT.title(20)),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GillMT.normal(18)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Create', style: GillMT.normal(18)),
              onPressed: () async {
                int collectionId = await NexaGuideDB().createCollection(_textFieldController.text, [], [], DateTime.now().millisecondsSinceEpoch);
                _loadCollections(); // Refresh the list of collections
                Navigator.pop(context);
                if (widget.selectMode) {
                  // If a new collection was created in selection mode, use it as the selected collection
                  Navigator.pop(context, collectionId);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCollection(int collectionId) async {
    // Confirm deletion
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Collection", style: GillMT.title(20)),
        content: Text("Are you sure you want to delete this collection?", style: GillMT.normal(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: GillMT.normal(18)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: GillMT.normal(18)),
          ),
        ],
      ),
    );

    // If confirmed, delete the collection
    if (confirm) {
      await NexaGuideDB().deleteCollection(collectionId);
      _loadCollections(); // Refresh the list of collections
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections', style: GillMT.title(22)),
      ),
      body: collections.isEmpty
          ? Center(
        child: Text('You have not saved any places yet.', style: GillMT.lighter(18)),
      )
          : ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          var collection = collections[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(collection.name, style: GillMT.normal(18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Locations: ${collection.poiIds.length}', style: GillMT.lighter(16)),
                  Text('Events: ${collection.eventIds.length}', style: GillMT.lighter(16)),
                ],
              ),
              onTap: () {
                if (widget.selectMode) {
                  Navigator.pop(context, collection.id);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionDetailPage(collection: collection),
                    ),
                  );
                }
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteCollection(collection.id),
              ),
            ),
          );
        },
      )
      ,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        tooltip: 'Create a new collection',
        child: Icon(Icons.add),
      ),
    );
  }
}
