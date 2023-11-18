import 'package:flutter/material.dart';

class eventDetailPage extends StatelessWidget {
  final int index;

  eventDetailPage(this.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Center(
        child: Text('Details for event $index'),
      ),
    );
  }
}
