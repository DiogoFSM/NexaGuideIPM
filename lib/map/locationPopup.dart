import 'package:flutter/material.dart';

import '../database/model/poi.dart';
import '../location/locationSinglePage.dart';

class LocationPopup extends StatefulWidget {
  final POI location;
  final void Function() closePopup;

  const LocationPopup({super.key, required this.location, required this.closePopup});

  @override
  State<LocationPopup> createState() => _LocationPopupState();

}

class _LocationPopupState extends State<LocationPopup> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(12.0),
      width: 300.0,
      height: 224.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black87,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5), //color of shadow
            spreadRadius: 4, //spread radius
            blurRadius: 6, // blur radius
            //offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible (
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.location.name,
                    style: const TextStyle(
                      inherit: false,
                      color: Colors.black,
                      fontFamily: 'GillSansMT',
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Material(
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.closePopup();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black26,
            thickness: 2,
          ),

          Flexible(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "${widget.location.cityName}\n\n ${widget.location.description}",
                          //widget.location.description!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            inherit: false,
                            color: Colors.black,
                            fontFamily: 'GillSansMT',
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                        ),
                      ),

                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.location.tags.toString(),
                          style: const TextStyle(
                            inherit: false,
                            color: Colors.black,
                            fontFamily: 'GillSansMT',
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                ),
                const SizedBox(width: 12),
                Flexible(
                    flex: 1,
                    child: Column (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: widget.location.photoURLs!.isNotEmpty ?
                          Image.network(widget.location.photoURLs!.first, width: 100, height: 100, fit: BoxFit.cover)
                        : Image.asset('assets/placeholder.png')
                          //Image(image: AssetImage('assets/placeholder.png'),)
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.closePopup();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LocationSinglePage (location: widget.location)));
                            },
                            child: const Text('View +', style: TextStyle(fontFamily: 'GillSansMT')),
                          ),
                        )
                      ],
                    )
                )
              ]
            )
          )
        ],
      ),
    );
  }

}