import 'dart:io';
import 'package:bank_msgs_app/models/bnk_transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper;

  static Database _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  String tableName = "bnk_transactions";
  String colBank = "bank";
  String colMonth = "month";
  String colYear = "year";
  String colDebitedAmt = "debited_amt";
  String colCreditedAmt = "credited_amt";

  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    //get directory path
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'transactions.db';

    var transactionsdatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return transactionsdatabase;
  }
    
  //Creating Table for each Bank Transcations' record
  void _createDb(Database db, int newVersion) async{
    await db.execute(
    '''CREATE TABLE $tableName(
      $colBank TEXT,
      $colMonth INTEGER, 
      $colYear INTEGER,
      $colDebitedAmt REAL, 
      $colCreditedAmt REAL,
      PRIMARY KEY ($colBank,$colMonth))
    '''.replaceAll('\n', ' ')
    );
  }

  //Insert Operation
  Future<int> insert(BnkTransaction bnkTransaction) async{
    Database db = await this.database;
    var result = db.insert(tableName, bnkTransaction.toMap());
    return result;
  }

  //Fetch Table opration - Get all BnkTransactions for the given table
  Future<List<Map<String,dynamic>>> getBnkTransactionMapList() async{
    Database db = await this.database;
    var result = await db.query(tableName);
    return result;
  }


  //Get the Map List and convert into BnkTransaction List
  Future<List<BnkTransaction>> getBnkTransactionList() async{
    var bnkTransactionMapList = await getBnkTransactionMapList();
    int count = bnkTransactionMapList.length;

    List<BnkTransaction> bnkTransactionList = List();
    for (var i = 0; i < count; i++) {
      bnkTransactionList.add(BnkTransaction.fromMapObject(bnkTransactionMapList[i]));
    }
    return bnkTransactionList;
  }

  //Query as per bank
    //Fetch map as per bank
    Future<List<Map<String,dynamic>>> _queryForABankMapList(String bnkName) async{
      List<String> args = List();
      args.add(bnkName);
      Database db = await this.database;
      var result = await db.query(tableName, where: '$colBank = ?', whereArgs: args, orderBy: '$colYear DESC, $colMonth DESC');
      return result;
    }
    //get maplist from above function and convert into BnkTrasaction List
    Future<List<BnkTransaction>> getBnkTransactionListPerBank(String bnkName) async{
      var bnkTransactionMapList = await _queryForABankMapList(bnkName);
      int count = bnkTransactionMapList.length;

      List<BnkTransaction> bnkTransactionList = List();
      for (var i = 0; i < count; i++) {
        bnkTransactionList.add(BnkTransaction.fromMapObject(bnkTransactionMapList[i]));
      }
      return bnkTransactionList;
    }


  //Delete db
  Future<int> delete() async{
    Database db = await this.database;
    int result = await db.delete(tableName);
    return result;
  }
    
}

