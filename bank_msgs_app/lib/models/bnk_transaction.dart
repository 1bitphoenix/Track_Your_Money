class BnkTransaction{
  String _bank;
  int _month;
  double _debitedAmt;
  double _creditedAmt;

  BnkTransaction(this._bank, this._month, this._debitedAmt, this._creditedAmt);

  //getters
  String get bank => _bank;
  int get month => _month;
  double get debitedAmt => _debitedAmt;
  double get creditedAmt => _creditedAmt;

  //setters
  set bank(String newBank){
    _bank = newBank;
  }
  set month(int newMonth) {
    _month = newMonth;
  }
  set debitedAmt(double newDebitedAmt){
    _debitedAmt = newDebitedAmt;
  }
  set creditedAmt(double newCreditedAmt){
    _creditedAmt = newCreditedAmt;
  }

  //Convert a BnkTransaction object into a Map object
   Map<String,dynamic> toMap(){
     Map<String,dynamic> map = Map();
     map['bank'] = _bank;
     map['month'] = _month;
     map['debited_amt'] =_debitedAmt;
     map['credited_amt'] = _creditedAmt;
     return map;
   }

   //Extract a BnkTransaction object from a Map object
   BnkTransaction.fromMapObject(Map<String,dynamic> map){
     this._bank = map['bank'];
     this._month = map['month'];
     this._debitedAmt = map['debited_amt'];
     this._creditedAmt = map['credited_amt'];
   }
}