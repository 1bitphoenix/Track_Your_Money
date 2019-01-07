import 'package:bank_msgs_app/charts/pie_chart.dart';
import 'package:bank_msgs_app/screens/monthwise_transaction_page.dart';
import 'package:flutter/material.dart';

class BankListItem extends StatelessWidget{
  final String bnkName;

  BankListItem(this.bnkName);

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => MonthWiseTransactionPage(bnkName)));
            },
      onDoubleTap: (){
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => PieChart(bnkName))
                );
            },
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.teal[700],
                width: 2.0,
              ),
              borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10), 
                                      bottomRight: Radius.circular(10)
                            )
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Center(child:Text(
                                      bnkName,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.teal[700]                                    
                                      ),
            ))), 
        )
    ));
  }
}