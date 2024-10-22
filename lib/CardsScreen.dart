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
    // Use a TextEditingController with the correct card name
    TextEditingController nameController = TextEditingController(
      text: card[DatabaseHelper.cardName] as String? ?? '',
    );

    // New variable to hold the selected folder ID
    int? selectedFolderId = card[DatabaseHelper.cardFolderId];

    // Get all folders from the database
    Future<List<Map<String, dynamic>>> _foldersFuture =
        widget.dbHelper.getFolders();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "New Card Name"),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _foldersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No Folders Found');
                  } else {
                    var folders = snapshot.data!;
                    return DropdownButton<int>(
                      value: selectedFolderId, // Display the current folder ID
                      onChanged: (int? newValue) {
                        // Update the selected folder ID
                        setState(() {
                          selectedFolderId = newValue;
                        });
                      },
                      items: folders.map<DropdownMenuItem<int>>((folder) {
                        return DropdownMenuItem<int>(
                          value: folder[DatabaseHelper.folderId],
                          child: Text(folder[DatabaseHelper.folderName]),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
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
                // Rename the card using the correct ID
                await widget.dbHelper.renameCard(
                  card[DatabaseHelper.cardId], // Use the card ID passed in
                  nameController.text,
                );
                // Move to the selected folder only if it has changed
                if (selectedFolderId != card[DatabaseHelper.cardFolderId]) {
                  await widget.dbHelper.moveCardToDifferentFolder(
                    card[DatabaseHelper.cardId],
                    selectedFolderId!,
                  );
                }
                _refreshUI();
                Navigator.of(context).pop();
              },
              child: Text("Save"),
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
