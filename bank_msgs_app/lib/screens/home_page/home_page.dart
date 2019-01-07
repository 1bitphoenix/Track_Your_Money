import 'package:bank_msgs_app/models/bnk_transaction.dart';
import 'package:bank_msgs_app/screens/home_page/bank_list_item.dart';
import 'package:bank_msgs_app/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bank_msgs_app/models/acc_transactions.dart';
import 'package:bank_msgs_app/utils/regexp.dart' as regexp
;

class HomePage extends StatefulWidget{
  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage>{

  DatabaseHelper _databaseHelper = DatabaseHelper();
  Set<String> bnkSet;
  Map<String,List<SmsMessage>> bnkMsgsMap = Map();

  final SmsQuery _query = new SmsQuery();

  bool _loading = true;
  int count = 0;

  void updateBankList(){
    
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database){

      Future<List<BnkTransaction>> bnkTransactionListFuture = _databaseHelper.getBnkTransactionList();
      bnkTransactionListFuture.then((bnkTransactionList){
        setState(() {
          _loading = false;
          bnkTransactionList.forEach((listItem){
            bnkSet.add(listItem.bank);
          });
          count = bnkSet.length;
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if(bnkSet == null){
      bnkSet = Set();
      updateBankList();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Accounts'),
          backgroundColor: Colors.teal[700],
          actions: <Widget>[
             IconButton(
               icon: Icon(Icons.receipt),
               onPressed: (){},
               tooltip: "Report Chart",
             )
          ],
        ),
        body: _homePageWidgets(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal[700],
          child: Icon(Icons.refresh),
          tooltip: 'Scan New Messages',
          onPressed: () async{
                 _databaseHelper.delete().then((res){                   
                    setState(() {              
                      _loading = true; 
                    });
                    _query.querySms({'kind': [SmsQueryKind.Inbox]}).then(_getMsgs);
                 });
          },
        ),
      ),
    );
  }
  Widget _homePageWidgets(){
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (bnkSet.isEmpty) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "Looks Like, it\'s empty here \n Click Refresh button to scan Transaction",
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey.withOpacity(0.5)
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
      child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1,
      children: bnkSet.map((String string){
        return BankListItem(string);
      }).toList(growable: false),
    ));
  }

  void _getMsgs(List<SmsMessage> messages) async{

  List<SmsMessage> _messages = new List();
    _messages = messages;
    print(_messages);
    if (_messages != null) {
      mapMsgsToBankNames(_messages);
    }
  }

  void mapMsgsToBankNames(List<SmsMessage> _messages){
    bnkMsgsMap = {
      'BOI': List(),
      'CANARA': List(),
      'KVB': List(),
      'HDFC': List(),
      'AXIS': List(),
    };
    for (var i = 0; i < _messages.length; i++) {
      String msgAddress = _messages[i].address;
      SmsMessage msg = _messages[i];
      print(msg);
      if (msgAddress.endsWith("BOIIND")) {
        bnkMsgsMap['BOI'].add(msg);
      }else if (msgAddress.endsWith("CANBNK")) {
        bnkMsgsMap['CANARA'].add(msg);
      }else if (msgAddress.endsWith("KVBANK")) {
        bnkMsgsMap['KVB'].add(msg);
      }else if (msgAddress.endsWith("HDFCBK")) {
        bnkMsgsMap['HDFC'].add(msg);
      }else if (msgAddress.endsWith("AxisBk")) {
        bnkMsgsMap['AXIS'].add(msg);
      }
    }
    addingToDB();
  }

  Map<String,AccTransactions> accMap ;
  void addingToDB(){
    bnkMsgsMap.forEach((bnkName, msgs){
      accMap = Map();
      if (msgs.length != 0) {
        msgs.forEach((msg){
          if (regexp.accNo.hasMatch(msg.body)) {

            String accNo = "XXXX" + getAccNo(msg.body);

            if (!accMap.containsKey(accNo)) {
              accMap[accNo] = AccTransactions(accNo);
              debugPrint(accNo);
            }

            if (regexp.credit1.hasMatch(msg.body)) {
              String string = regexp.credit1.stringMatch(msg.body);
              getCreditAmts(accMap[accNo], msg.date.month, string);
            } 
            else if (regexp.deposit1.hasMatch(msg.body)) {
              String string = regexp.deposit1.stringMatch(msg.body);
              getCreditAmts(accMap[accNo], msg.date.month,string);
            }
            else if (regexp.credit2.hasMatch(msg.body)) {
              String string = regexp.credit2.stringMatch(msg.body);
              getCreditAmts(accMap[accNo], msg.date.month, string);
            }
            else if (regexp.deposit2.hasMatch(msg.body)) {
              String string = regexp.deposit2.stringMatch(msg.body);
              getCreditAmts(accMap[accNo], msg.date.month, string);
            }
            else if (regexp.debit1.hasMatch(msg.body)) {
              String string = regexp.debit1.stringMatch(msg.body);
              getDebitAmts(accMap[accNo], msg.date.month, string);
            } 
            else if(regexp.debit2.hasMatch(msg.body)){
              String string = regexp.debit2.stringMatch(msg.body);
              getDebitAmts(accMap[accNo], msg.date.month, string);
            }
          }
        });
      }
      accMap.forEach((accNo, acc){
        BnkTransaction transMonth1 = BnkTransaction(bnkName,accNo,acc.month1,acc.year1,acc.debitedAmt1,acc.creditedAmt1);
        BnkTransaction transMonth2 = BnkTransaction(bnkName,accNo,acc.month2,acc.year2,acc.debitedAmt2,acc.creditedAmt2);
        BnkTransaction transMonth3 = BnkTransaction(bnkName,accNo,acc.month3,acc.year3,acc.debitedAmt3,acc.creditedAmt3);
        
        _databaseHelper.insert(transMonth1);
        _databaseHelper.insert(transMonth2);
        _databaseHelper.insert(transMonth3);
      });
    });
    updateBankList();
  }
  void getCreditAmts(AccTransactions account, int month, String string){
    if (month == account.month1) {
      account.creditedAmt1 += _getAmountFromString(string); 
    } else if(month == account.month2){
      account.creditedAmt2 += _getAmountFromString(string);
    } else if (month == account.month3) {
      account.creditedAmt3 += _getAmountFromString(string);
    }
  }
  void getDebitAmts(AccTransactions account, int month, String string){
    if (month == account.month1) {
      account.debitedAmt1 += _getAmountFromString(string); 
    } else if(month == account.month2){
      account.debitedAmt2 += _getAmountFromString(string);
    } else if (month == account.month3) {
      account.debitedAmt3 += _getAmountFromString(string);
    }
  }
  String getAccNo(String msg){
      var accNo = regexp.accNo.stringMatch(msg);
      RegExp exp = RegExp(r"\d*(X|\*)*\d\d\d\d");
      return exp.stringMatch(accNo);
  }

  double _getAmountFromString(String string){
    RegExp exp = RegExp(r"\d+\.*\d*");
    double amount = double.parse(exp.stringMatch(string));
    amount = double.parse(amount.toStringAsPrecision(2));
    return amount;
  }
}