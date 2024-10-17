import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizerDatabase.db";
  static const _databaseVersion = 1;

  // Folder table
  static const folderTable = 'folders';
  static const folderId = '_id';
  static const folderName = 'folder_name';
  static const folderTimestamp = 'timestamp';

  // Cards table
  static const cardsTable = 'cards';
  static const cardId = '_id';
  static const cardName = 'name';
  static const cardSuit = 'suit';
  static const cardImageUrl = 'image_url';
  static const cardFolderId = 'folder_id';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the Folders and Cards tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $folderTable (
  $folderId INTEGER PRIMARY KEY,
  $folderName TEXT NOT NULL,
  $folderTimestamp TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $cardsTable (
  $cardId INTEGER PRIMARY KEY,
  $cardName TEXT NOT NULL,
  $cardSuit TEXT NOT NULL,
  $cardImageUrl TEXT NOT NULL,
  $cardFolderId INTEGER,
  FOREIGN KEY ($cardFolderId) REFERENCES $folderTable ($folderId)
)
''');

    // Insert initial folder data (Hearts, Spades, Diamonds, Clubs)
    await _insertInitialFolders(db);

    // Insert initial card data with suit-based image URLs
    await _insertInitialCards(db);
  }

  // Insert initial folders (Hearts, Spades, Diamonds, Clubs)
  Future<void> _insertInitialFolders(Database db) async {
    List<String> folderNames = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    String timestamp = DateTime.now().toIso8601String();

    for (String name in folderNames) {
      await db.insert(folderTable, {
        folderName: name,
        folderTimestamp: timestamp,
      });
    }
  }

  // Insert all standard cards into the Cards table
  Future<void> _insertInitialCards(Database db) async {
    List<Map<String, dynamic>> cards = [];

    // Define suits and their folder IDs (IDs will depend on the insertion order)
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    Map<String, int> folderIds = {
      'Hearts': 1,
      'Spades': 2,
      'Diamonds': 3,
      'Clubs': 4,
    };

    // Adds hearts
    cards.add({
      DatabaseHelper.cardName:
          "Ace of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile000.png",
      DatabaseHelper.cardFolderId: folderIds["Hearts"],
    });
    cards.add({
      DatabaseHelper.cardName: "2 of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile001.png",
      DatabaseHelper.cardFolderId: folderIds["Hearts"],
    });
    cards.add({
      DatabaseHelper.cardName: "3 of Hearts", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Hearts",
      DatabaseHelper.cardImageUrl: "assets/images/Hearts/htile002.png",
      DatabaseHelper.cardFolderId: folderIds["Hearts"],
    });
    // Spades
    cards.add({
      DatabaseHelper.cardName:
          "Ace of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile000.png",
      DatabaseHelper.cardFolderId: folderIds["Spades"],
    });
    cards.add({
      DatabaseHelper.cardName: "2 of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile001.png",
      DatabaseHelper.cardFolderId: folderIds["Spades"],
    });
    cards.add({
      DatabaseHelper.cardName: "3 of Spades", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Spades",
      DatabaseHelper.cardImageUrl: "assets/images/Spades/Stile002.png",
      DatabaseHelper.cardFolderId: folderIds["Spades"],
    });
    // Diamonds
    cards.add({
      DatabaseHelper.cardName:
          "Ace of Diamonds", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Diamonds",
      DatabaseHelper.cardImageUrl: "assets/images/Diamonds/Dtile000.png",
      DatabaseHelper.cardFolderId: folderIds["Diamonds"],
    });
    cards.add({
      DatabaseHelper.cardName:
          "2 of Diamonds", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Diamonds",
      DatabaseHelper.cardImageUrl: "assets/images/Diamonds/Dtile001.png",
      DatabaseHelper.cardFolderId: folderIds["Diamonds"],
    });
    cards.add({
      DatabaseHelper.cardName:
          "3 of Diamonds", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Diamonds",
      DatabaseHelper.cardImageUrl: "assets/images/Diamonds/Dtile002.png",
      DatabaseHelper.cardFolderId: folderIds["Diamonds"],
    });
    // Clubs
    cards.add({
      DatabaseHelper.cardName:
          "Ace of Clubs", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Clubs",
      DatabaseHelper.cardImageUrl: "assets/images/Clubs/Ctile000.png",
      DatabaseHelper.cardFolderId: folderIds["Clubs"],
    });
    cards.add({
      DatabaseHelper.cardName: "2 of Clubs", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Clubs",
      DatabaseHelper.cardImageUrl: "assets/images/Clubs/Ctile001.png",
      DatabaseHelper.cardFolderId: folderIds["Clubs"],
    });
    cards.add({
      DatabaseHelper.cardName: "3 of Clubs", // Use 'name' or cardName constant
      DatabaseHelper.cardSuit: "Clubs",
      DatabaseHelper.cardImageUrl: "assets/images/Clubs/Ctile002.png",
      DatabaseHelper.cardFolderId: folderIds["Clubs"],
    });

    // Bulk insert cards into the database
    for (var card in cards) {
      await db.insert(cardsTable, card);
    }
  }

  // Helper function to get card name (1 = Ace, 11 = Jack, 12 = Queen, 13 = King)
  String _getCardName(int value) {
    switch (value) {
      case 1:
        return 'Ace';
      case 11:
        return 'Jack';
      case 12:
        return 'Queen';
      case 13:
        return 'King';
      default:
        return value.toString();
    }
  }

  // TODO: Other CRUD methods (insert, query, update, delete) remain the same, must be implemented.

  // First Helper Method: Create Folder, inserts a new folder to the database.
  Future<int> insertFolder(String name) async {
    final timestamp = DateTime.now().toIso8601String();
    Map<String, dynamic> row = {
      folderName: name,
      folderTimestamp: timestamp,
    };
    return await _db.insert(folderTable, row);
  }

  // Create Card, inserts a new card into the folder
  Future<int> insertCard(
      String name, String suit, String imageUrl, int folderId) async {
    Map<String, dynamic> row = {
      cardName: name,
      cardSuit: suit,
      cardImageUrl: imageUrl,
      cardFolderId: folderId,
    };
    return await _db.insert(cardsTable, row);
  }

  // Fetch all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _db.query(folderTable);
  }

  // Fetch Cards in a Folder
  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    return await _db.query(
      cardsTable,
      where: '$cardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  // Update folder details
  Future<int> updateFolder(int id, String newName) async {
    Map<String, dynamic> row = {
      folderName: newName,
      folderTimestamp: DateTime.now().toIso8601String(),
    };
    return await _db.update(
      folderTable,
      row,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  // Update card details
  Future<int> updateCard(int cardId, String newName, int newFolderId) async {
    Map<String, dynamic> row = {
      cardName: newName,
      cardFolderId: newFolderId,
    };
    return await _db.update(
      cardsTable,
      row,
      where: '$cardId = ?',
      whereArgs: [cardId],
    );
  }

  // Delete folder (also deletes all cards in the folder)
  Future<int> deleteFolder(int id) async {
    // Delete all cards in the folder
    await _db.delete(
      cardsTable,
      where: '$cardFolderId = ?',
      whereArgs: [id],
    );

    // Delete the folder itself
    return await _db.delete(
      folderTable,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  // Delete just one card
  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cardsTable,
      where: '$cardId = ?',
      whereArgs: [id],
    );
  }
}
