import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatelessWidget {
  final int folderID;
  final String folderName;
  final DatabaseHelper dbHelper;

  CardsScreen(
      {required this.folderID,
      required this.folderName,
      required this.dbHelper,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards in $folderName'),
      ),
      body: Center(
        child:
            Text('Display cards here for folder $folderName with ID $folderID'),
      ),
    );
  }
}
