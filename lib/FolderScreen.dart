import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'CardsScreen.dart'; // Make sure to import your CardsScreen

class FoldersScreen extends StatelessWidget {
  final DatabaseHelper dbHelper;

  FoldersScreen({required this.dbHelper, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folders"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getFolders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Folders Found'));
          } else {
            var folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(folders[index][DatabaseHelper.folderName]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(
                          folderID: folders[index][DatabaseHelper.folderId],
                          folderName: folders[index][DatabaseHelper.folderName],
                          dbHelper: dbHelper,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
