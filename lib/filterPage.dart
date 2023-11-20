import 'package:flutter/material.dart';
import 'package:nexaguide_ipm/appBar.dart';
import 'package:nexaguide_ipm/text_styles/TextStyleGillMT.dart';

class FilterPage extends StatefulWidget {
  final ApplyFilterCallback onApply;

  const FilterPage({super.key, required this.onApply});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  //int selectedPrice = 0;
  int selectedMinPrice = 0;
  int selectedMaxPrice = 200;
  //int selectedStars = 0;
  int selectedStarsMin = 0;
  int selectedStarsMax = 5;
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  double selectedDistance = 0.0;
  TimeOfDay? selectedTime;
  List<String> selectedCategories = [];
  List<String> allCategories = [
    'Historical',
    'Cultural',
    'Restaurant',
    'Shopping',
    'Adventure',
    'Outdoors',
    'For Kids',
  ];

  void showFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filters', style: GillMT.title(20)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
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
                     */

                    Text('Price range: $selectedMinPrice - $selectedMaxPrice €', style: GillMT.normal(18)),
                    RangeSlider(
                      values: RangeValues(selectedMinPrice.toDouble(), selectedMaxPrice.toDouble()),
                      onChanged: (newValues) {
                        setState(() {
                          selectedMinPrice = newValues.start.toInt();
                          selectedMaxPrice = newValues.end.toInt();
                        });
                      },
                      min: 0.0,
                      max: 200.0,
                      divisions: 40,
                    ),
                    SizedBox(height: 20),

                    /*
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
                     */

                    Text('Rating:  $selectedStarsMin - $selectedStarsMax ★', style: GillMT.normal(18),),
                    RangeSlider(
                      values: RangeValues(selectedStarsMin.toDouble(), selectedStarsMax.toDouble()),
                      onChanged: (newValues) {
                        setState(() {
                          selectedStarsMin = newValues.start.toInt();
                          selectedStarsMax = newValues.end.toInt();
                        });
                      },
                      min: 0.0,
                      max: 5.0,
                    ),
                    SizedBox(height: 20),

                    /*
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
                     */

                    Text('Distance: ${selectedDistance.toStringAsFixed(2)} km', style: GillMT.normal(18)),
                    Slider(
                      value: selectedDistance,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDistance = newValue;
                        });
                      },
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                    ),
                    SizedBox(height: 20),

                    Text('Tags:', style: GillMT.normal(18)),
                    Wrap(
                      spacing: 8.0,
                      children: List<Widget>.generate(allCategories.length, (int index) {
                        return FilterChip(
                          label: Text(allCategories[index], style: GillMT.normal(16)),
                          selected: selectedCategories.contains(allCategories[index]),
                          selectedColor: Colors.orange,
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            widget.onApply(
                              minPrice: selectedMinPrice,
                              maxPrice: selectedMaxPrice,
                              minRating: selectedStarsMin,
                              maxRating: selectedStarsMax,
                              distance: selectedDistance,
                              tags: selectedCategories
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text('Apply', style: GillMT.normal(18)),
                        ),
                      ],
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
