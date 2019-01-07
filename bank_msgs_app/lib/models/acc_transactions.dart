import 'package:bank_msgs_app/utils/values.dart';

class AccTransactions{

  String accNo;
  var month1 = DateTime.now().month;
  var month2;
  var month3;
  var year1 = DateTime.now().year;
  var year2;
  var year3;
  double creditedAmt1 = 0;
  double creditedAmt2 = 0;
  double creditedAmt3 = 0;
  double debitedAmt1 = 0;
  double debitedAmt3 = 0;
  double debitedAmt2 = 0;

  AccTransactions(this.accNo){
    month2 = previousMonth(month1);
    month3 = previousMonth(month2);
    year2 = whichYear(year1, month1);
    year3 = whichYear(year2, month2);
  }
}