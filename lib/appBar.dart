import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NexaGuideAppBar extends StatelessWidget {
  const NexaGuideAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(actions: [
      Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: () {
                  // do something
                },
                child: Ink.image(
                  image: AssetImage('assets/nexaguide3.png'),
                  fit: BoxFit.scaleDown,
                  width: 40,
                  height: 40,
                  child: InkWell(
                    splashColor: Colors.black.withOpacity(0.5),
                    highlightColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

/*


 */
}
