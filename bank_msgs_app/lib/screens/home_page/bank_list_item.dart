import 'package:flutter/material.dart';

class BankListItem extends StatelessWidget{
  String bnkName;

  BankListItem(this.bnkName);

  @override
  Widget build(BuildContext context){
    return Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.teal[900],
                width: 2.0,
              ),
              borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10), 
                                      bottomRight: Radius.circular(10)
                            )
            ),
            child:GestureDetector( 
              child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Center(child:Text(
                                      bnkName,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.teal[900]                                    
                                      ),
              ))),
              onTap: (){

              },
              onDoubleTap: (){
                
              },
            )
        ));
  }
}