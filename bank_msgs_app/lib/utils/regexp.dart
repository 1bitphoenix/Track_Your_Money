RegExp credit1 = RegExp(r"(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*.*CREDITED", caseSensitive: false);
RegExp credit2 = RegExp(r"CREDITED.*(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*", caseSensitive: false);
RegExp debit1 = RegExp(r"(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*.*DEBITED", caseSensitive: false);
RegExp debit2 = RegExp(r"DEBITED.*(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*", caseSensitive: false);
RegExp deposit1 = RegExp(r"(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*.*DEPOSITED", caseSensitive: false);
RegExp deposit2 = RegExp(r"DEPOSITED.*(INR|Rs\.|Rs) *\d+(,\d+)*\.?\d*", caseSensitive: false);
RegExp accNo = RegExp(r"(Ac|A\c|credit card)(-|\.)* *(\w+\.? ){0,2}\d*(X|\*)*\d\d\d\d", caseSensitive: false);
