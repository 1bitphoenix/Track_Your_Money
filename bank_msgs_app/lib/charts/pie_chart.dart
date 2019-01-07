import 'package:bank_msgs_app/models/bnk_transaction.dart';
import 'package:bank_msgs_app/utils/database_helper.dart';
import 'package:bank_msgs_app/utils/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:sqflite/sqflite.dart';



class PieChart extends StatefulWidget {
  String name;
  PieChart(this.name);
  @override
  _PieChartState createState() => _PieChartState(name);
}

class _PieChartState extends State<PieChart> {

  String name;
  _PieChartState(this.name);

  List<List<CircularStackEntry>> _monthyTransactionPieData;

  List<BnkTransaction> transactionList;

  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _loading = true;

  void updateList(){
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database){

      Future<List<BnkTransaction>> bnkTransactionListFuture = _databaseHelper.
                                                                  getBnkTransactionListPerBank(name);
      bnkTransactionListFuture.then((bnkTransactionList){
        print(bnkTransactionList);
        setState(() {
          transactionList = bnkTransactionList;
          setmonthyTransactionPieData();
          creditAmt = transactionList.first.creditedAmt;
          debitAmt = transactionList.first.debitedAmt;
          month = transactionList.first.month;
          _loading = false;
        });
      });
    });
  }

  void setmonthyTransactionPieData(){
    _monthyTransactionPieData = List();
    transactionList.forEach((item){
      Color debitColor = Colors.yellowAccent[100];
      Color creditColor = Colors.blue[200];
      double debit = item.debitedAmt;
      double credit = item.creditedAmt;
      if (item.debitedAmt == 0) {
        debitColor = Colors.brown[100];
        debit = 50;
      }
      if (item.creditedAmt == 0) {
        creditColor = Colors.blueGrey[200];
        credit = 50;
      }
      _monthyTransactionPieData.add(
          <CircularStackEntry>[
          new CircularStackEntry(
              <CircularSegmentEntry>[
                      new CircularSegmentEntry(debit,debitColor, rankKey: 'Debit Amount'),
                      new CircularSegmentEntry(credit, creditColor, rankKey: 'Credit Amount'),
                ],
              rankKey: monthMap[item.month],
            ),
          ]
      );
    });
  }

  double creditAmt = 0;
  double debitAmt = 0;
  int month;

  final GlobalKey<AnimatedCircularChartState> _chartKey = GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(300.0, 300.0);
  int index = 0;
  
  void _cycleMonths() {
    setState(() {
      index++;
      creditAmt = transactionList[index % 3].creditedAmt;
      debitAmt = transactionList[index % 3].debitedAmt;
      month = transactionList[index % 3].month;
      List<CircularStackEntry> data = _monthyTransactionPieData[index % 3];
      _chartKey.currentState.updateData(data);
    });
  }
  
  @override
  Widget build(BuildContext context) {

    if(transactionList == null){
      transactionList = List();
      updateList();
    }
    return new Scaffold(
      appBar: new AppBar(
        title: Text(name),
        backgroundColor: Colors.teal[700],
      ),
      body: _screenWidget(),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.teal[700],
        child: new Icon(Icons.next_week),
        onPressed: _cycleMonths,
      ),
    );
  }

  Widget _screenWidget(){
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(),
      );      
    }
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Credit : $creditAmt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Colors.blue[900]
                            ),
                          ),
                          Text(
                            'Debit : $debitAmt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Colors.yellow[900]
                            ),
                          )
                        ],
                      ),
                      AnimatedCircularChart(
                        key: _chartKey,
                        size: _chartSize,
                        initialChartData: _monthyTransactionPieData[0],
                        chartType: CircularChartType.Pie,
                      ),
                      Text(
                        monthMap[month],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                          color: Colors.teal[900]
                        ),
                      )
          ],
      )
    );
  }
}