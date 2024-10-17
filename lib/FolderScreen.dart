import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'CardsScreen.dart'; // Make sure to import your CardsScreen

class FoldersScreen extends StatelessWidget {
  final DatabaseHelper dbHelper;

  FoldersScreen({required this.dbHelper, Key? key}) : super(key: key);

  final List<Map<String, dynamic>> folders = [
    {'name': 'Hearts', 'id': 1},
    {'name': 'Clubs', 'id': 2},
    {'name': 'Spades', 'id': 3},
    {'name': 'Diamonds', 'id': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(folders[index]['name']),
            onTap: () {
              // Pass both folderID and dbHelper to the CardsScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardsScreen(
                    folderID: folders[index]['id'],
                    folderName: folders[index]['name'],
                    dbHelper: dbHelper,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
