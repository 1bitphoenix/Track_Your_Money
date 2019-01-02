Map monthMap = {
  1: 'January', 
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December'
};

var numOfResultMonths = 3;

var totalMonthsInYear = 12;

int previousMonth(int month){
  int _previousMonth = month - 1;
  if(_previousMonth == 0){
    return totalMonthsInYear;
  }
  return _previousMonth;
}