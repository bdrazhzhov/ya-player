class Account {
  final int uid;
  final String login;
  final String fullName;
  final String firstName;
  final String secondName;
  final String displayName;
  final bool serviceAvailable;

  Account(this.uid, this.login, this.fullName, this.firstName,
      this.secondName, this.displayName, this.serviceAvailable);

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(json['uid'], json['login'], json['fullName'],
        json['firstName'], json['secondName'], json['displayName'],
        json['serviceAvailable']);
  }
}

class AccountStatus {
  final Account? account;

  AccountStatus(this.account);
}
