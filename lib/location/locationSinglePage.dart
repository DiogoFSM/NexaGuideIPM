import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

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
          padding: const EdgeInsets.all(14),
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
    String priceText = (location.price != null) ? (location.price! > 0 ? "${location.price!} €" : "Free") : '???';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: GillMT.normal(18),),
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
                      linkStyle: TextStyle(color: Colors.blue),
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

          const Divider(color: Colors.black87, thickness: 0.2),

          Text(location.description ?? '(No description available)' , style: GillMT.normal(18).copyWith(height: 1.3), textAlign: TextAlign.justify,),
        ],
      )

      /*
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location.name, style: GillMT.normal(18),),
                const Divider(color: Colors.black87, thickness: 1),

                Text("• City:  ${location.cityName ?? '???'}", style: GillMT.normal(18),),
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
                  linkStyle: TextStyle(color: Colors.blue),
                ),
                Text("Tags:  ${location.tags}" , style: GillMT.normal(18).copyWith(height: 1.3),),
                const Divider(color: Colors.black87, thickness: 1),

                Text(location.description ?? '(No description available)' , style: GillMT.normal(18).copyWith(height: 1.3), textAlign: TextAlign.justify,),
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
      */

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
