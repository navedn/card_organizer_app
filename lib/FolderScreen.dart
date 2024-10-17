import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'CardsScreen.dart'; // Make sure to import your CardsScreen

class FoldersScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  FoldersScreen({required this.dbHelper, Key? key}) : super(key: key);

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  Future<List<Map<String, dynamic>>>? _foldersFuture;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    _foldersFuture = widget.dbHelper.getFolders();
  }

// Function to add a new folder
  Future<void> _addFolder() async {
    TextEditingController folderNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: "Folder Name"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  await widget.dbHelper.insertFolder(folderNameController.text);
                  setState(() {
                    _loadFolders();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update a folder
  Future<void> _updateFolder(int folderId, String currentName) async {
    TextEditingController folderNameController =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: "New Folder Name"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  await widget.dbHelper.updateFolder(
                    folderId,
                    folderNameController.text,
                  );
                  setState(() {
                    _loadFolders();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a folder
  Future<void> _deleteFolder(int folderId) async {
    await widget.dbHelper.deleteFolder(folderId);
    setState(() {
      _loadFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folders"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _foldersFuture,
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
                return Dismissible(
                  key: Key(folders[index][DatabaseHelper.folderId].toString()),
                  background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                    _deleteFolder(folders[index][DatabaseHelper.folderId]);
                  },
                  child: ListTile(
                    title: Text(folders[index][DatabaseHelper.folderName]),
                    onTap: () {
                      // Navigate to CardsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardsScreen(
                            folderID: folders[index][DatabaseHelper.folderId],
                            folderName: folders[index]
                                [DatabaseHelper.folderName],
                            dbHelper: widget.dbHelper,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Open the update dialog
                      _updateFolder(folders[index][DatabaseHelper.folderId],
                          folders[index][DatabaseHelper.folderName]);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        child: Icon(Icons.add),
      ),
    );
  }
}
