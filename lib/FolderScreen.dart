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

  // Function to load all folders from the database
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

  // Function to update a folder's name
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
                  await widget.dbHelper
                      .updateFolder(folderId, folderNameController.text);
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete this folder?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await widget.dbHelper.deleteFolder(folderId);
                setState(() {
                  _loadFolders();
                });
                Navigator.of(context).pop();
              },
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
        title: Text('Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFolder,
          ),
        ],
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
                var folder = folders[index];

                return FutureBuilder(
                  future: Future.wait([
                    widget.dbHelper
                        .getCardCountInFolder(folder[DatabaseHelper.folderId]),
                    widget.dbHelper.getFirstCardImageInFolder(
                        folder[DatabaseHelper.folderId]),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: Text('Loading card info...'),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: Text('Error loading card info'),
                      );
                    } else {
                      int cardCount = snapshot.data![0] as int;
                      String? firstCardImageUrl = snapshot.data![1] as String?;

                      return ListTile(
                        leading: firstCardImageUrl != null
                            ? Image.asset(
                                firstCardImageUrl,
                                fit: BoxFit
                                    .cover, // This will cover the whole container without distorting
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image,
                                      size: 50); // Fallback icon
                                },
                              )
                            : Icon(Icons.image, size: 50),
                        title: Text(folder[DatabaseHelper.folderName]),
                        subtitle: Text('$cardCount cards'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _updateFolder(
                                folder[DatabaseHelper.folderId],
                                folder[DatabaseHelper.folderName],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteFolder(
                                folder[DatabaseHelper.folderId],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardsScreen(
                                folderID: folder[DatabaseHelper.folderId],
                                folderName: folder[DatabaseHelper.folderName],
                                dbHelper: widget.dbHelper,
                              ),
                            ),
                          );
                        },
                      );
                    }
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
