class BnkTransaction{
  String _bank;
  String _accountNo;
  int _year;
  int _month;
  double _debitedAmt;
  double _creditedAmt;

  BnkTransaction(this._bank, this._accountNo, this._month, this._year, this._debitedAmt, this._creditedAmt);

  //getters
  String get bank => _bank;
  String get accountNo => _accountNo;
  int get month => _month;
  int get year => _year;
  double get debitedAmt => _debitedAmt;
  double get creditedAmt => _creditedAmt;

  //setters
  set bank(String newBank){
    _bank = newBank;
  }
  set accountNo(String newAccountNo){
    _accountNo = newAccountNo;
  }
  set month(int newMonth) {
    _month = newMonth;
  }
  set year(int newYear) {
    _year = newYear;
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
     map['account_no'] = _accountNo;
     map['month'] = _month;
     map['year'] = _year;
     map['debited_amt'] =_debitedAmt;
     map['credited_amt'] = _creditedAmt;
     return map;
   }

   //Extract a BnkTransaction object from a Map object
   BnkTransaction.fromMapObject(Map<String,dynamic> map){
     this._bank = map['bank'];
     this._accountNo = map['account_no'];
     this._month = map['month'];
     this._year = map['year'];
     this._debitedAmt = map['debited_amt'];
     this._creditedAmt = map['credited_amt'];
   }
}