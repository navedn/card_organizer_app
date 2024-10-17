import 'package:flutter/material.dart';
import 'FolderScreen.dart';
import 'database_helper.dart'; // Import the database helper

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  final dbHelper = DatabaseHelper(); // Create a database helper instance
  await dbHelper.init(); // Initialize the database
  runApp(MyApp(dbHelper: dbHelper)); // Pass the database helper to the app
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper; // Store the database helper

  const MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FoldersScreen(dbHelper: dbHelper), // Pass dbHelper to FolderScreen
    );
  }
}
