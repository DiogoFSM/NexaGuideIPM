import 'package:flutter/material.dart';

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
              DetailsSection(location: location),
              Divider(),
              Section(
                title: 'Section 2',
                content: 'This is the content of section 2.',
              ),
              Divider(),
              Section(
                title: 'Section 3',
                content: 'This is the content of section 3.',
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
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.name, style: GillMT.normal(16),),
                Text("Address: ${location.address ?? '(Unknown)'}" , style: GillMT.normal(16),),
                Text(location.name, style: GillMT.normal(16),),
              ],
            )
          ),

          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(location.name),
              ],
            )
          ),
        ],
      ),
    );
  }

}


class Section extends StatelessWidget {
  final String title;
  final String content;

  const Section({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
