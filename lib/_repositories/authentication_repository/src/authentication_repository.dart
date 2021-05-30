import 'dart:async';
import 'dart:convert';

import 'package:app_qldt/_utils/database/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/services.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get stream async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<bool> logIn(LoginUser loginUser) async {
    final loginService = LoginService(loginUser);

    String? response = await loginService.login();
    LoginResponse loginResponse;

    if (response == null) {
      // _controller.add(AuthenticationStatus.unauthenticated);
      return false;
    }

    loginResponse = LoginResponse.fromJson(jsonDecode(response));

    if (loginResponse.message == 'success') {
      await _saveUserInfo(jsonEncode(loginResponse.info));
      _controller.add(AuthenticationStatus.authenticated);
      return true;
    }

    _controller.add(AuthenticationStatus.unauthenticated);
    return false;
  }

  Future<void> _saveUserInfo(String info) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_info', info);
  }

  Future<void> logOut() async {
    await DatabaseProvider.deleteDb();
    await _removeUserInfo();

    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    _controller.close();
  }

  Future<void> _removeUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user_info');
  }
}
