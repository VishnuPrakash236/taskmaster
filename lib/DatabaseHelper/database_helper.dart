import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "office_task_management.db";
  late int _databaseVersion = 5;

  static final tableUsers = 'users';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnRole = 'role';
  static const String columnOverAllPercentage = 'OverAllPercentage';
  static const String profile = 'profile';
  static const String columnImgPath = 'imgPath';

  static final tableTasks = 'tasks';
  static final columnTaskId = '_taskID'; // Updated column name
  static final columnEmployeeName = 'employee_name';
  static final columnTaskName = 'task_name';
  static final columnTaskType = 'task_type';
  static final columnPriority = 'priority';
  static final columnDueDate = 'due_date';
  static const String columnStatus = 'status';
  static const String columnRemarks = 'remarks';
  static const String columnRemarksSubject = 'remarks_subject';
  static const String columnRemarksStat = 'remarks_status';
  static const String columnCompletedPercentage = 'completedPercentage';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnTaskId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTaskName TEXT,
        $columnTaskType TEXT,
        $columnPriority TEXT,
        $columnDueDate TEXT,
        $columnEmployeeName TEXT,
        $columnStatus TEXT,
        $columnCompletedPercentage INTEGER,
        $columnRemarks TEXT       
      )
    ''');

    // Insert initial admin user data
    await db.rawInsert('''
      INSERT INTO $tableUsers ($columnName, $columnEmail, $columnPassword, $columnRole)
      VALUES ('admin', 'admin@example.com', 'admin', 'admin')
    ''');
    // _onUpgrade(db,0,0);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Oldversion=" + oldVersion.toString());
    print("NewVersion=" + newVersion.toString());
    if (1 < _databaseVersion) {
      // Upgrade to version 2
      var result = await db.rawQuery("PRAGMA table_info($tableTasks)");
      bool columnExists =
          result.any((element) => element['name'] == '$columnRemarksStat');

      if (!columnExists) {
        // Add the column if it does not exist
        await db.execute(
            'ALTER TABLE $tableTasks ADD COLUMN $columnRemarksStat TEXT');
        print("Column '$columnRemarksStat' added to '$tableTasks'.");
      } else {
        print("Column '$columnRemarksStat' already exists in '$tableTasks'.");
      }
    }
    if (2 < _databaseVersion) {
      // Upgrade to version 3
      var result = await db.rawQuery("PRAGMA table_info($tableUsers)");
      bool columnExists = result
          .any((element) => element['name'] == '$columnOverAllPercentage');

      if (!columnExists) {
        // Add the column if it does not exist
        await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN $columnOverAllPercentage INT');
        print("Column '$columnOverAllPercentage' added to '$tableUsers'.");
      } else {
        print(
            "Column '$columnOverAllPercentage' already exists in '$tableUsers'.");
      }
    }
    if (3 < _databaseVersion) {
      // Upgrade to version 3
      var result = await db.rawQuery("PRAGMA table_info($tableUsers)");
      bool columnExists =
          result.any((element) => element['name'] == '$profile');

      if (!columnExists) {
        // Add the column if it does not exist
        await db.execute('ALTER TABLE $tableUsers ADD COLUMN $profile BLOB');
        print("Column '$profile' added to '$tableUsers'.");
      } else {
        print("Column '$profile' already exists in '$tableUsers'.");
      }
    }
    if (4 < _databaseVersion) {
      // Upgrade to version 4
      var result = await db.rawQuery("PRAGMA table_info($tableUsers)");
      bool columnExists =
          result.any((element) => element['name'] == '$columnImgPath');

      if (!columnExists) {
        // Add the column if it does not exist
        await db
            .execute('ALTER TABLE $tableUsers ADD COLUMN $columnImgPath TEXT');
        print("Column '$columnImgPath' added to '$tableUsers'.");
      } else {
        print("Column '$columnImgPath' already exists in '$tableUsers'.");
      }
    }
  }

  Future<int> getDatabaseVersion() async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA user_version');
    _onUpgrade(db, 0, 0);
    return result.first['user_version'] as int;
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.query(tableUsers);
  }

  Future<List<Map<String, dynamic>>> queryAllUsers2() async {
    Database db = await instance.database;
    return await db.rawQuery(
        'SELECT $columnId,$columnName,$columnEmail,$columnPassword,$columnRole,$columnImgPath FROM $tableUsers');
  }

  Future<Map<String, dynamic>?> getUserProfilePath(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(tableUsers,
        columns: [columnImgPath],
        where: '$columnEmail = ?',
        whereArgs: [email]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Uint8List?> getUserProfile(String userMail) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      tableUsers,
      columns: [profile],
      where: '$columnEmail = ?',
      whereArgs: [userMail],
    );

    if (results.isNotEmpty && results.first[profile] != null) {
      return results.first[profile] as Uint8List;
    } else {
      return null; // Handle case where profile is not found
    }
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    Database db = await instance.database;
    return await db.rawQuery(
        'SELECT $columnTaskId,$columnCompletedPercentage,$columnEmployeeName FROM $tableTasks');
  }

  Future<List<Map<String, dynamic>>> getOverAll() async {
    Database db = await instance.database;
    return await db.rawQuery(
        "SELECT $columnName, $columnOverAllPercentage FROM $tableUsers WHERE $columnName <> 'admin'");
  }

  // Future<List<Map<String, dynamic>>> getAllTasks() async {
  //   Database db = await instance.database;
  //   return await db
  //       .rawQuery('SELECT $columnName,$columnOverAllPercentage FROM $tableUsers');
  // }

  Future<List<String>> queryAllEmployeeNames() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db
        .query(tableUsers, where: '$columnRole != ?', whereArgs: ['admin']);
    List<String> employeeNames =
        results.map((e) => e['name'] as String).toList();
    return employeeNames;
  }

  Future<List<int>> getUserCompletePercentage(String empName) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.rawQuery(
        "SELECT $columnCompletedPercentage FROM $tableTasks WHERE $columnEmployeeName ='$empName' AND $columnCompletedPercentage IS NOT NULL");
    List<int>? completePercentage = results
        .map((e) => e['$columnCompletedPercentage'])
        .cast<int>()
        .toList();
    return completePercentage;
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, row);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(tableUsers, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    int rowsAffected = await db.update(
      tableUsers,
      user,
      where: '$columnId = ?',
      whereArgs: [user[columnId]],
    );
    return rowsAffected;
  }

  Future<int> updateRemarks(Map<String, dynamic> remark) async {
    Database db = await instance.database;
    int rowsAffected = await db.update(
      tableTasks,
      remark,
      where: '$columnTaskId = ?',
      whereArgs: [remark[columnTaskId]],
    );
    return rowsAffected;
  }

  Future<int> updateRemarksAsRead(Map<String, dynamic> remark) async {
    Database db = await instance.database;
    int rowsAffected = await db.update(
      tableTasks,
      remark,
      where: '$columnTaskId = ?',
      whereArgs: [remark[columnTaskId]],
    );
    return rowsAffected;
  }

  // Future<int> updateOverAll()

  Future<Map<String, dynamic>?> queryUser(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db
        .query(tableUsers, where: '$columnEmail = ?', whereArgs: [email]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>?> queryResultStatus() async {
    Database db = await instance.database;
    // List<Map<String, dynamic>> results = await db
    //     .query(tableTasks, where: '$columnRemarksStat = ?', whereArgs: ['not_opened']);
    List<Map<String, dynamic>> results = await db.rawQuery(
        "SELECT $columnRemarksStat FROM $tableTasks WHERE $columnRemarksStat ='not_opened';");
    return results.isNotEmpty ? results : null;
  }

  Future<List<Map<String, dynamic>>> getRemarksForAdmin() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.rawQuery(
        "SELECT * FROM $tableTasks WHERE $columnRemarksStat ='not_opened';");
    return results;
  }

  Future<bool> userExists(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db
        .query(tableUsers, where: '$columnEmail = ?', whereArgs: [email]);
    return results.isNotEmpty;
  }

  Future<int> insertTask(Map<String, dynamic> taskData) async {
    Database db = await database;
    return await db.insert(tableTasks, taskData);
  }

  Future<int> insertOverAll(Map<String, dynamic> overAllData) async {
    Database db = await database;
    return await db.update(tableUsers, overAllData,
        where: '$columnName = ?', whereArgs: [overAllData[columnName]]);
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    Database db = await instance.database;
    return await db.update(
      tableTasks,
      task,
      where: '$columnTaskId = ?',
      whereArgs: [task[columnTaskId]],
    );
  }

  Future<List<Map<String, dynamic>>> getTasksForUser(
      String employeeName) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      tableTasks,
      where: '$columnEmployeeName = ?',
      whereArgs: [employeeName],
    );
    return results;
  }

  Future<bool> hasAssignedTask(String employeeName) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(tableTasks,
        where: '$columnEmployeeName = ?', whereArgs: [employeeName]);
    return results.isNotEmpty;
  }

  Future<String> _getEmployeeNameByEmail(String email) async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> results = await db.query(
        tableUsers,
        columns: [columnName],
        where: '$columnEmail = ?',
        whereArgs: [email],
      );
      if (results.isNotEmpty) {
        return results.first[columnName];
      } else {
        return ''; // Handle case where employee with given email doesn't exist
      }
    } catch (e) {
      print('Error fetching employee name: $e');
      return ''; // Handle error gracefully
    }
  }

  Future<int> deleteTask(int taskId) async {
    try {
      Database db = await instance.database;
      int rowsAffected = await db.delete(
        tableTasks,
        where: '$columnTaskId = ?',
        whereArgs: [taskId],
      );
      return rowsAffected;
    } catch (e) {
      print('Error deleting task: $e');
      return -1; // Return an error code or handle gracefully as needed
    }
  }

  Future<int> deleteAllTasksForUser(String employeeName) async {
    try {
      Database db = await instance.database;
      return await db.delete(
        tableTasks,
        where: '$columnEmployeeName = ?',
        whereArgs: [employeeName],
      );
    } catch (e) {
      print('Error deleting tasks for user: $e');
      return -1; // Return an error code or handle gracefully as needed
    }
  }

  Future<Map<String, dynamic>> getTaskById(int? taskId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      tableTasks,
      where: '$columnTaskId = ?',
      whereArgs: [taskId],
    );
    return results.isNotEmpty ? results.first : {};
  }

  // Public column accessor for _taskID
  String get taskIDColumn => columnTaskId;
}
