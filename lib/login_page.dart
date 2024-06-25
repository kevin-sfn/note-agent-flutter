import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/api_service.dart';
import 'data/login_response.dart';

import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with SingleTickerProviderStateMixin {
  TextEditingController? _idTextController;
  TextEditingController? _pwTextController;
  String result = '';
  String _loginId = '';
  String _loginPw = '';
  bool _isAutoLogin = false;
  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _loadPreferences().then((_) {
      setState(() {
        _idTextController?.text = _loginId;
        _pwTextController?.text = _loginPw;
        if (_isAutoLogin) {
          _checkAutoLogin();
        }
      });
    });

    storage.write(key: 'access_token', value: '');
    storage.write(key: 'store_id', value: '');
    storage.write(key: 'oauth_access_token', value: '');
    storage.write(key: 'oauth_refresh_token', value: '');

    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();

    // _idTextController?.text = 'johncook0412';
    // _pwTextController?.text = 'john@sfn#1';
    // _idTextController?.text = '123456';
    // _pwTextController?.text = 'afour0712';
    // _idTextController?.text = 'sfood1987';
    // S_pwTextController?.text = 'sfood2294**';
    _idTextController?.text = _loginId;
    _pwTextController?.text = _loginPw;

    _checkAutoLogin();
  }

  @override
  void dispose() {
    // _animationController!.dispose();
    super.dispose();
  }

  Future<bool> _login() async {
    String? loginId = _idTextController?.text;
    String? loginPw = _pwTextController?.text;

    // String loginId = 'johncook0412';
    // String loginPw = 'john@sfn#1';
    String appType = 'POS_AGENT';

    bool loginResult = false;

    try {
      // ApiService의 login 함수 호출
      Map<String, dynamic> response =
          await ApiService.login(loginId!, loginPw!, appType);
      // 로그인 성공 시 처리
      print('로그인 성공: $response');
      // TODO: 로그인 성공 시 다음 화면으로 이동
      Map<String, dynamic> jsonData = response;
      var data = jsonData['data'];

      LoginResponse loginResponse = LoginResponse.fromJson(data);

      await storage.write(
          key: 'access_token', value: loginResponse.accessToken);
      await storage.write(
          key: 'store_id', value: loginResponse.storeId.toString());
      await storage.write(
          key: 'oauth_access_token', value: loginResponse.access_token);
      await storage.write(
          key: 'oauth_refresh_token', value: loginResponse.refresh_token);

      // print('Response.data: $data');
      print('data.accessToken: ${data['accessToken']}');

      _loginId = loginId;
      _loginPw = loginPw;
      _savePreferences();

      loginResult = true;
    } catch (e) {
      // 로그인 실패 시 처리
      print('로그인 실패: $e');
      // TODO: 로그인 실패 시 오류 메시지를 사용자에게 표시
    }

    return loginResult;
  }

  void _checkAutoLogin() async {
    if (_isAutoLogin) {
      bool loginOk = await _login();
      if (loginOk) {
        Navigator.of(context).pushReplacementNamed('/main');
        // _enabledPin();
      }
    }
  }

  Future<bool> _enabledPin() async {
    // String loginId = 'johncook0412';
    // String loginPw = 'john@sfn#1';
    // String appType = 'POS_AGENT';

    bool pinResult = false;

    try {
      // ApiService의 login 함수 호출
      Map<String, dynamic> response = await ApiService.oauthPinEnabled();
      // 로그인 성공 시 처리
      print('로그인 성공: $response');
      // TODO: 로그인 성공 시 다음 화면으로 이동
      // Map<String, dynamic> jsonData = response;
      // var data = jsonData['data'];

      pinResult = true;
    } catch (e) {
      // 로그인 실패 시 처리
      print('enabledPin 실패: $e');
      // TODO: 로그인 실패 시 오류 메시지를 사용자에게 표시
    }

    return pinResult;
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAutoLogin = prefs.getBool('isAutoLogin') ?? false;
    _loginId = prefs.getString('loginId') ?? '';
    _loginPw = prefs.getString('loginPw') ?? '';
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAutoLogin', _isAutoLogin);
    prefs.setString('loginId', _loginId);
    prefs.setString('loginPw', _loginPw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 336,
            child: Row(
              children: [
                // Spacer(),
                Image.asset(
                  'assets/images/login_app_icon.png',
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  '안녕하세요. 사장님,\r\n차별화상회 계정으로 로그인하세요.',
                  style: TextStyle(
                      color: Color.fromRGBO(0x00, 0x00, 0xF1, 1),
                      fontSize: 18.5),
                ),
                // Spacer(),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          SizedBox(
            width: 336,
            height: 50,
            child: Row(
              children: [
                Text('로그인 ID'),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextField(
                    controller: _idTextController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(), // 기본 언더라인 설정
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(
                                0x00, 0x00, 0xF1, 1)), // 포커스 시 언더라인 색상 변경
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: 336,
            height: 50,
            child: Row(
              children: [
                Text('패스워드'),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextField(
                    controller: _pwTextController,
                    obscureText: true,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(), // 기본 언더라인 설정
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(
                                0x00, 0x00, 0xF1, 1)), // 포커스 시 언더라인 색상 변경
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: SizedBox(
              width: 336,
              height: 50,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAutoLogin = !_isAutoLogin;
                      });
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      // 패딩 제거
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent), // 눌렸을 때 투명 색상 설정
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          _isAutoLogin
                              ? 'assets/images/checkbox_checked.png'
                              : 'assets/images/checkbox_unchecked.png',
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text(
                          '자동 로그인',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 336,
            height: 60,
            child: TextButton(
              onPressed: () async {
                bool loginOk = await _login();
                if (loginOk) {
                  // _savePreferences();
                  Navigator.of(context).pushReplacementNamed('/main');
                  // _enabledPin();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF0000F1)),
                // 배경색 설정
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(50), // 좌측 반원
                      right: Radius.circular(50), // 우측 반원
                    ),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                // 글자색 설정
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blue.withOpacity(0.5); // 눌렸을 때의 색상 설정
                    }
                    return null; // 다른 상태에서는 기본 색상 사용
                  },
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () async {
                    var url = 'https://www.google.com';
                    var response = await http.get(Uri.parse(url));
                    setState(() {
                      result = response.body;
                    });
                    // Navigator.of(context).pushNamed('/sign');
                  },
                  child: const Text('회원가입하기')),
              const Text('|',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              TextButton(
                  onPressed: () async {
                    var url = 'https://www.google.com';
                    var response = await http.get(Uri.parse(url));
                    setState(() {
                      result = response.body;
                    });
                    // Navigator.of(context).pushNamed('/sign');
                  },
                  child: const Text('아이디 / 비밀번호 찾기')),
            ],
          )
        ],
      ),
    ));
  }

  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
