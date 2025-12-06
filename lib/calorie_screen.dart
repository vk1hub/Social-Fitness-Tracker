import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalorieScreen extends StatefulWidget {
  @override
  CalorieScreenState createState() => CalorieScreenState();
}

class CalorieScreenState extends State<CalorieScreen> {

  TextEditingController foodController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  List<Map<String, dynamic>> foods = [];

  // calender state
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  void loadFoods() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String>? foodNames = prefs.getStringList('food_names');
    List<String>? foodCalories = prefs.getStringList('food_calories');
    List<String>? foodDates = prefs.getStringList('food_dates');
    
    if (foodNames == null || foodCalories == null || foodDates == null) {
      return;
    }
    
    // creates the foods list
    List<Map<String, dynamic>> loadedFoods = [];
    for (int i = 0; i < foodNames.length; i++) {
      loadedFoods.add({
        'name': foodNames[i],
        'calories': int.parse(foodCalories[i]),
        'date': DateTime.parse(foodDates[i]),
      });
    }
    
    setState(() {
      foods = loadedFoods;
    });
  }

  void saveFoods() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> foodNames = [];
    List<String> foodCalories = [];
    List<String> foodDates = [];
    
    for (int i = 0; i < foods.length; i++) {
      foodNames.add(foods[i]['name']);
      foodCalories.add(foods[i]['calories'].toString());
      foodDates.add((foods[i]['date'] as DateTime).toString());
    }
    await prefs.setStringList('food_names', foodNames);
    await prefs.setStringList('food_calories', foodCalories);
    await prefs.setStringList('food_dates', foodDates);
  }

  // calculate total calories for selected date
  int getTotalCalories() {
    int total = 0;
    for (int i = 0; i < foods.length; i++) {
      DateTime foodDate = foods[i]['date'];
      if (foodDate.year == selectedDate.year &&
          foodDate.month == selectedDate.month &&
          foodDate.day == selectedDate.day) {
        total += foods[i]['calories'] as int;
      }
    }
    return total;
  }

  // get foods for selected date
  List<Map<String, dynamic>> getFoodsForSelectedDate() {
    List<Map<String, dynamic>> todaysFoods = [];
    for (int i = 0; i < foods.length; i++) {
      DateTime foodDate = foods[i]['date'];
      if (foodDate.year == selectedDate.year &&
          foodDate.month == selectedDate.month &&
          foodDate.day == selectedDate.day) {
        todaysFoods.add(foods[i]);
      }
    }
    return todaysFoods;
  }

  // add food function
  void addFood() {
    if (foodController.text.isEmpty || caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      foods.add({
        'name': foodController.text,
        'calories': int.parse(caloriesController.text),
        'date': selectedDate,
      });

      foodController.clear();
      caloriesController.clear();
    });
    saveFoods();
  }

  // remove food function
  void removeFood(int index) {
    setState(() {
      Map<String, dynamic> foodToRemove = getFoodsForSelectedDate()[index];
      foods.remove(foodToRemove);
    });
    saveFoods();
  }

  @override
  Widget build(BuildContext context) {
    int totalCalories = getTotalCalories();
    List<Map<String, dynamic>> todaysFoods = getFoodsForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                '$totalCalories cal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          
          // calendar widget
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: focusedDate,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
                focusedDate = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // food input
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: foodController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // calories input
                Expanded(
                  child: TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addFood,
                  child: Text('Add'),
                ),
              ],
            ),
          ),

          // Food list section
          Expanded(
            child: todaysFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'No food logged yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: todaysFoods.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            todaysFoods[index]['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${todaysFoods[index]['calories']} cal',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => removeFood(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}