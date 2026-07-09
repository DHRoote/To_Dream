import 'package:flutter/material.dart';

// 공용 데이터 바구니 역할을 할 클래스입니다.
class UserProvider with ChangeNotifier {
  String _userId = ''; // 실제 데이터가 저장될 변수
  String _nickname = '';

  // 바구니에서 데이터를 꺼내볼 때 쓰는 메서드 (Get)
  String get userId => _userId;
  String get nickname => _nickname;

  // 바구니에 데이터를 넣을 때 쓰는 메서드 (Set)
  void setUserId(String id) {
    _userId = id;
    notifyListeners(); // "데이터가 바뀌었어!" 하고 앱 전체에 방송하는 역할
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners(); // "데이터가 바뀌었어!" 하고 앱 전체에 방송하는 역할
  }

  // 로그아웃 시 사용자 정보 초기화
  void clearUser() {
    _userId = '';
    _nickname = '';
    notifyListeners();
  }
}