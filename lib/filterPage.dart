import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/appBar.dart';

class FilterPage extends StatefulWidget {
  final ApplyFilterCallback onApply;

  const FilterPage({super.key, required this.onApply});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  int selectedPrice = 0;
  int selectedStars = 0;
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  double selectedDistance = 0.0;
  TimeOfDay? selectedTime;
  List<String> selectedCategories = [];
  List<String> allCategories = [
    'Music',
    'Historical',
    'Event',
    'Cultural',
    'For Kids',
    'Open Space',
    'Adventure'
  ];

  void showFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filters'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: $selectedPrice €'),
                    Slider(
                      value: selectedPrice.toDouble(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedPrice = newValue.toInt();
                        });
                      },
                      min: 0.0,
                      max: 100.0,
                    ),
                    SizedBox(height: 20),

                    Text('Stars: $selectedStars'),
                    Slider(
                      value: selectedStars.toDouble(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedStars = newValue.toInt();
                        });
                      },
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: '$selectedStars',
                    ),
                    SizedBox(height: 20),

                    Text('Days of the Week:'),
                    Wrap(
                      spacing: 8.0,
                      children: List<Widget>.generate(7, (int index) {
                        return FilterChip(
                          label: Text(getDayLabel(index)),
                          selected: selectedDays[index],
                          onSelected: (bool value) {
                            setState(() {
                              selectedDays[index] = value;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),

                    Text('Distance: ${selectedDistance.toStringAsFixed(2)} km'),
                    Slider(
                      value: selectedDistance,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDistance = newValue;
                        });
                      },
                      min: 0.0,
                      max: 50.0,
                    ),
                    SizedBox(height: 20),

                    Text('Categories:'),
                    Wrap(
                      spacing: 8.0,
                      children: List<Widget>.generate(allCategories.length, (int index) {
                        return FilterChip(
                          label: Text(allCategories[index]),
                          selected: selectedCategories.contains(allCategories[index]),
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                selectedCategories.add(allCategories[index]);
                              } else {
                                selectedCategories.remove(allCategories[index]);
                              }
                            });
                          },
                        );
                      }),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          minPrice: 0,
                          maxPrice: selectedPrice,
                          minRating: selectedStars,
                          maxRating: 5,
                          distance: selectedDistance,
                          tags: selectedCategories
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getDayLabel(int index) {
    switch (index) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.tune_rounded),
      onPressed: () {
        showFilters();
      },
      iconSize: 28,
    );
  }
}
