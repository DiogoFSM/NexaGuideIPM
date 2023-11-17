import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/model/poi.dart';

class LocationPopup extends StatefulWidget {
  final POI location;

  const LocationPopup({super.key, required this.location});

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
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // TODO: close popup
                  },
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
                          widget.location.description!,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),

                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.location.tags.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                ),

                Flexible(
                    flex: 1,
                    child: Column (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Image(
                            image: AssetImage('assets/placeholder.png'), // TODO: Get an image
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Go to POI detailed page
                            },
                            child: const Text('View +')
                          ),
                        )
                      ],
                    )
                )
              ]
            )
          )

          /*
          Flexible (
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.location.description!,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Image(
                          image: AssetImage('assets/nexaguide3.png'),

                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.location.tags.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      ElevatedButton(
                          onPressed: () {
                            // TODO: Go to POI detailed page
                          },
                          child: const Text('View +')
                      )
                    ]
                  )
                )
              ],
            ),
          ),
          */
        ],
      ),
    );
  }

}