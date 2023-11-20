import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../database/nexaguide_db.dart';

class ReviewPage extends StatefulWidget {
  final String placeName;
  final String userName;
  final String userPhotoUrl; // This should be a path to the user's photo or a URL

  const ReviewPage({
    Key? key,
    required this.placeName,
    required this.userName,
    required this.userPhotoUrl,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles;
  double _currentRating = 0;
  bool old =false;
  @override
  void initState() {
    super.initState();
    _loadReview(); // Load the review when the widget is first created
  }

  Future<void> _loadReview() async {
    try {
      final List<Map<String, dynamic>> reviewDataList = await NexaGuideDB().fetchReviewsByUserAndPlace(widget.userName, widget.placeName);
      if (reviewDataList.isNotEmpty) {
        old=true;
        final reviewData = reviewDataList.first;
        print('Review Data: $reviewData'); // Debugging line

        setState(() {
          _currentRating = reviewData['rating'];
          _reviewController.text = reviewData['reviewText'] ?? '';

          // Handle the images
          if (reviewData['images'] != null) {
            // If images are stored as a single string of comma-separated paths
            var imagePathString = reviewData['images'];
            if (imagePathString is String && imagePathString.isNotEmpty) {
              _imageFiles = imagePathString.split(',').map((path) => XFile(path)).toList();
            }
            // If images are directly stored as a List<String>
            else if (imagePathString is List<String>) {
              _imageFiles = imagePathString.map((path) => XFile(path)).toList();
            }
            else {
              _imageFiles = [];
            }
          } else {
            _imageFiles = [];
          }
        });
      }
    } catch (e) {
      print('Failed to load review: $e');
    }
  }
  void _deleteReview() async {
    try {
      await NexaGuideDB().deleteReview(widget.userName, widget.placeName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Optionally, reset the form fields and state
      _reviewController.clear();
      setState(() {
        old=false;
        _currentRating = 0;
        _imageFiles = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateReview() async {
    // This can call the same _submitReview function or a separate update function
    // that calls NexaGuideDB().updateReview
    _submitReview();
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _imageFiles = selectedImages;
      });
    }
  }

  void _submitReview() async {
    // Assuming you have a user object or username and placeName available
    final String username = widget.userName; // Replace with actual username
    final String placeName = widget.placeName; // Assuming this is the name of the place
    print(placeName+username);
    // Convert the list of image XFiles to a list of their path strings
    List<String> imagePaths = _imageFiles?.map((xFile) => xFile.path).toList() ?? [];
    print(imagePaths);
    // Insert the review into the database
    try {
      await NexaGuideDB().insertReview(
        username: username,
        placeName: placeName,
        rating: _currentRating,
        reviewText: _reviewController.text,
        images: imagePaths,
      );
      // If insert is successful, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Optionally, reset the form fields
      _reviewController.clear();
      Navigator.pop(context);
      setState(() {
        _currentRating = 0;
        _imageFiles = [];
      });
    } catch (e) {
      print(e);
      // If an error occurs, show a different SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete') {
                _deleteReview();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(widget.userName),
              // Uncomment the following line if you want to show the user's photo
              // leading: CircleAvatar(
              //   backgroundImage: NetworkImage(widget.userPhotoUrl), // Or use AssetImage for a local file
              // ),
            ),
            RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _currentRating = rating;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _reviewController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _imageFiles!.map((file) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InkWell(
                        onTap: () => _showFullImage(file.path), // Show full image on tap
                        child: Image.file(
                          File(file.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if(!old)IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeImage(file),
                      ),
                    ],
                  )).toList(),
                ),
              ),

           if(!old)ElevatedButton(
              onPressed: _pickImages,
              child: Text('Upload Images'),
              style:ElevatedButton.styleFrom(
                primary:Colors.amber
              )
              ,
            ),
            if(!old)ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Background color
                onPrimary: Colors.black, // Text Color (Foreground color)
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _removeImage(XFile file) {
    setState(() {
      _imageFiles!.remove(file);
    });
  }
  void _showFullImage(String imagePath) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
    ));
  }
}
