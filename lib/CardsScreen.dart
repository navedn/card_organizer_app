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
        title: Text("Cards in Folder"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getCardsInFolder(folderID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Cards Found'));
          } else {
            var cards = snapshot.data!;
            return ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cards[index][DatabaseHelper.cardName]),
                  subtitle: Text(cards[index][DatabaseHelper.cardSuit]),
                  leading: Image.asset(
                    cards[index]
                        [DatabaseHelper.cardImageUrl], // Load image from asset

                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                          Icons.abc); // Fallback icon if the image isn't found
                    },
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
