import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WebTab {
  int id;
  String url;

  WebTab({this.id, this.url});

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'url' : url
    };
  }

  String get getTabIdToThreeWords {
    if(id < 10) return "00" + id.toString();
    else if(id < 100) return "0" + id.toString();
    else return id.toString();
  }

  static Future<Database> get database async {
    print("database get");

    return openDatabase(join(await getDatabasesPath(), 'tab_database.db'),
        onCreate: (db, version) => db.execute(
          "CREATE TABLE webtabs(id INTEGER PRIMARY KEY, url TEXT)",
        ),
        version: 1);
  }

  // Define a function that inserts dogs into the database
  static Future<void> insertWebTab(WebTab webTab) async {
    print("insert webtab");

    // Get a reference to the database.
    final Database db = await database;

    await db.insert(
      'webtabs',
      webTab.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<WebTab>> getAllWebTabs() async {
    print("get all webtab");

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('webtabs');

    return List.generate(maps.length, (i) {
      return WebTab(
        id: maps[i]['id'],
        url: maps[i]['url']
      );
    });
  }

  static Future<void> deleteWebTab(int id) async {
    final db = await database;

    await db.delete(
      'webtabs',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}