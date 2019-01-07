import 'package:bank_msgs_app/charts/bar_chart.dart';
import 'package:bank_msgs_app/models/bnk_transaction.dart';
import 'package:bank_msgs_app/screens/home_page/bank_list_item.dart';
import 'package:bank_msgs_app/utils/database_helper.dart';
import 'package:bank_msgs_app/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sqflite/sqflite.dart';

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
               onPressed: (){
                //  Navigator.push(
                //    context, 
                //    MaterialPageRoute(builder: (context) => SimpleBarChart())
                //   );
               },
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
                    _query.querySms(kinds: [SmsQueryKind.Inbox]).then(_getMsgs);
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
            "Looks Like, its empty here \n Click Refresh button to scan Transaction",
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
    makingTransactionObjects();
  }

  void makingTransactionObjects(){
    bnkMsgsMap.forEach((bnkName, msgs) async {     

      if(msgs.length != 0){
        print(msgs.length);
      
      var month1 = DateTime.now().month;
      var month2 = previousMonth(month1);
      var month3 = previousMonth(month2);
      var year1 = DateTime.now().year;
      var year2 = whichYear(year1, month1);
      var year3 = whichYear(year2, month2);
      double creditedAmt1 = 0;
      double creditedAmt2 = 0;
      double creditedAmt3 = 0;
      double debitedAmt1 = 0;
      double debitedAmt3 = 0;
      double debitedAmt2 = 0;
      
      RegExp expForCredit1 = RegExp(r"(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*.*CREDITED", caseSensitive: false);
      RegExp expForCredit2 = RegExp(r"CREDITED.*(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*", caseSensitive: false);
      RegExp expForDebit1 = RegExp(r"(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*.*DEBITED", caseSensitive: false);
      RegExp expForDebit2 = RegExp(r"DEBITED.*(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*", caseSensitive: false);
      RegExp expForDeposit1 = RegExp(r"(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*.*DEPOSTED", caseSensitive: false);
      RegExp expForDeposit2 = RegExp(r"DEPOSITED.*(INR|INR |Rs\.|Rs\. |Rs|Rs )\d+\.*\d*", caseSensitive: false);
      msgs.forEach((msg){
        if (expForCredit1.firstMatch(msg.body) != null) {
          var string = expForCredit1.stringMatch(msg.body);
          if (msg.date.month == month1) {

            creditedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            creditedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            creditedAmt3 += _getAmountFromString(string);
          }
        }
        else if (expForCredit2.firstMatch(msg.body) != null) {
          var string = expForCredit2.stringMatch(msg.body);
          if (msg.date.month == month1) {
            creditedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            creditedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            creditedAmt3 += _getAmountFromString(string);
          }          
        }
        else if (expForDebit1.firstMatch(msg.body) != null) {
          var string = expForDebit1.stringMatch(msg.body);
          if (msg.date.month == month1) {
            debitedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            debitedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            debitedAmt3 += _getAmountFromString(string);
          }          
        }
        else if (expForDebit2.firstMatch(msg.body) != null) {
          var string = expForDebit2.stringMatch(msg.body);
          if (msg.date.month == month1) {
            debitedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            debitedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            debitedAmt3 += _getAmountFromString(string);
          }          
        }
        else if (expForDeposit1.firstMatch(msg.body) != null) {
          var string = expForDeposit1.stringMatch(msg.body);
          if (msg.date.month == month1) {
            creditedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            creditedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            creditedAmt3 += _getAmountFromString(string);
          }          
        }
        else if (expForDeposit2.firstMatch(msg.body) != null) {
          var string = expForDeposit2.stringMatch(msg.body);
          if (msg.date.month == month1) {
            creditedAmt1 += _getAmountFromString(string);
          }else if(msg.date.month == month2){
            creditedAmt2 += _getAmountFromString(string);
          }else if (msg.date.month == month3) {
            creditedAmt3 += _getAmountFromString(string);
          }          
        }
      });

      debitedAmt1 = num.parse(debitedAmt1.toStringAsPrecision(2));
      debitedAmt2 = num.parse(debitedAmt2.toStringAsPrecision(2));
      debitedAmt3 = num.parse(debitedAmt3.toStringAsPrecision(2));
      creditedAmt1 = num.parse(creditedAmt1.toStringAsPrecision(2));
      creditedAmt2 = num.parse(creditedAmt2.toStringAsPrecision(2));
      creditedAmt3 = num.parse(creditedAmt3.toStringAsPrecision(2));
      

      BnkTransaction transMonth1 = BnkTransaction(bnkName,month1, year1, debitedAmt1, creditedAmt1);
      BnkTransaction transMonth2 = BnkTransaction(bnkName,month2, year2, debitedAmt2, creditedAmt2);
      BnkTransaction transMonth3 = BnkTransaction(bnkName,month3, year3, debitedAmt3, creditedAmt3);
        
      _databaseHelper.insert(transMonth1);
      _databaseHelper.insert(transMonth2);
      _databaseHelper.insert(transMonth3);
        debugPrint(transMonth1.month.toString());
        debugPrint(transMonth2.month.toString());
        debugPrint(transMonth3.month.toString());
      
    }
    });
    updateBankList();
  }

  double _getAmountFromString(String string){
    RegExp exp = new RegExp(r"\d+\.*\d*");
    double amount = double.parse(exp.stringMatch(string));
    return amount;
  }

}