import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/database/nexaguide_db.dart';
import 'package:nexaguide_ipm/database/model/collection.dart';

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
          title: Text('Create a new collection'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Create'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
      ),
      body: collections.isEmpty
          ? Center(
        child: Text('You have not saved any places yet.'),
      )
          : ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          var collection = collections[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(collection.name),
              subtitle: Text('Events: ${collection.eventIds.length}'),
              onTap: () {
                if (widget.selectMode) {
                  // Return the selected collection ID
                  Navigator.pop(context, collection.id);
                } else {
                  // Navigate to collection details page or perform other actions
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        tooltip: 'Create a new collection',
        child: Icon(Icons.add),
      ),
    );
  }
}
