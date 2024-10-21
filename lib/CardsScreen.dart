// cards_screen.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final int folderID;
  final String folderName;
  final DatabaseHelper dbHelper;

  CardsScreen({
    required this.folderID,
    required this.folderName,
    required this.dbHelper,
    Key? key,
  }) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Future<List<Map<String, dynamic>>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = widget.dbHelper.getCardsInFolder(widget.folderID);
  }

  void _refreshUI() {
    setState(() {
      _loadCards();
    });
  }

  void _showRenameDialog(Map<String, dynamic> card) {
    TextEditingController nameController =
        TextEditingController(text: card[DatabaseHelper.cardName]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rename Card"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "New Card Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.dbHelper.renameCard(
                  card[DatabaseHelper.cardId],
                  nameController.text,
                );
                _refreshUI();
                Navigator.of(context).pop();
              },
              child: Text("Rename"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cards in ${widget.folderName}"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cardsFuture,
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
                var card = cards[index];
                return ListTile(
                  title: Text(card[DatabaseHelper.cardName]),
                  trailing: IconButton(
                    icon: Icon(Icons.edit), // Edit icon
                    onPressed: () =>
                        _showRenameDialog(card), // Show rename dialog
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
