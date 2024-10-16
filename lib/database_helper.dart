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

    // Insert cards (1-13 for each suit)
    for (String suit in suits) {
      for (int i = 1; i <= 13; i++) {
        String cardName = _getCardName(i);
        String imageUrl =
            'https://example.com/images/$cardName-of-$suit.png'; // Example URL format
        cards.add({
          cardName: cardName,
          cardSuit: suit,
          cardImageUrl: imageUrl,
          cardFolderId: folderIds[suit],
        });
      }
    }

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
}
