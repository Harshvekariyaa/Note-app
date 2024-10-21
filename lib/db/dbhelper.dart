import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Dbhelper {
  Dbhelper._();

  static final Dbhelper instance = Dbhelper._();
  static final String TBLNAME = "tblnote";
  static final String COLUMN_TITLE = "title";
  static final String COLUMN_SUBTITLE = "subtitle";
  static final String COLUMN_ID = "nId"; // Add the column ID for delete and update

  Database? db;

  // Method to get the Database instance
  Future<Database> getDB() async {
    if (db != null) {
      return db!;
    } else {
      db = await openDB(); // Await the result of openDB before returning db
      return db!;
    }
  }

  // Method to open the Database
  Future<Database> openDB() async {
    Directory dirpath = await getApplicationDocumentsDirectory();
    String dbpath = join(dirpath.path, "note.db");

    try {
      return await openDatabase(dbpath, onCreate: (db, version) {
        db.execute(
            "CREATE TABLE $TBLNAME($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_TITLE TEXT, $COLUMN_SUBTITLE TEXT)"
        );
      }, version: 2); // Ensure version bump to recreate DB
    } catch (e) {
      print("Error opening database: $e");
      rethrow; // Handle or propagate the error accordingly
    }
  }

  // Method to add a note
  Future<bool> addNote({required String mtitle, required String mSubtitle}) async {
    var db = await getDB();
    int rowAffected = await db.insert(TBLNAME, {
      COLUMN_TITLE: mtitle,
      COLUMN_SUBTITLE: mSubtitle,
    });

    return rowAffected > 0;
  }

  // Method to retrieve all notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await getDB();
    return await db.query(TBLNAME);
  }

  // Method to delete a note by its ID
  Future<int> deleteNoteById(int id) async {
    var db = await getDB();
    return await db.delete(TBLNAME, where: '$COLUMN_ID = ?', whereArgs: [id]);
  }

  // Method to update a note by its ID
  Future<int> updateNoteById(int id, {required String newTitle, required String newSubtitle}) async {
    var db = await getDB();
    return await db.update(
      TBLNAME,
      {
        COLUMN_TITLE: newTitle,
        COLUMN_SUBTITLE: newSubtitle,
      },
      where: '$COLUMN_ID = ?',
      whereArgs: [id],
    );
  }
}
