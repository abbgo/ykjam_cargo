import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoradge with ChangeNotifier {
  // VARIABLES -----------------------------------------------------------------
  static late SharedPreferences _sharedPrefOject;

  String _guestToken = "";
  String _fcmPushNotificationToken = "";
  String _userToken = "";
  String _userCode = "";
  String _userName = "";
  int _userID = 0;
  List<String> _ids = [];

  // FUNCTIONS -----------------------------------------------------------------
  createSharedPrefObject() async {
    _sharedPrefOject = await SharedPreferences.getInstance();
  }

  // POST IDS FUNCTIONS -----------------------------------------------------------------
  List<String> getPostIDS() => _ids;

  changePostIDToSharedPref(String id) {
    List<String> postIds = _sharedPrefOject.getStringList("ids") ?? [];

    if (postIds.isEmpty) {
      postIds.add(id);
    } else {
      bool hasID = false;
      for (var postID in postIds) {
        if (postID == id) {
          hasID = true;
        }
      }

      if (hasID) {
        postIds.remove(id);
      } else {
        postIds.add(id);
      }
    }

    _sharedPrefOject.setStringList("ids", postIds);
    _ids = postIds;
    notifyListeners();
  }

  getPostIdsFromSharedPref() {
    if (_sharedPrefOject.getStringList("ids") != null) {
      _ids = _sharedPrefOject.getStringList("ids")!;
    }
  }

  // GUEST TOKEN FUNCTIONS
  String getGuestToken() => _guestToken;

  saveGuestTokenToSharedPref(String value) {
    _sharedPrefOject.setString("guest_token", value);
  }

  getGuestTokenFromSharedPref() {
    if (_sharedPrefOject.getString("guest_token") != null) {
      _guestToken = _sharedPrefOject.getString("guest_token")!;
    }
  }

  void changeGuestToken(String token) {
    _guestToken = token;
    saveGuestTokenToSharedPref(_guestToken);
    notifyListeners();
  }

  // FCM TOKEN FUNCTIONS
  String getFcmToken() => _fcmPushNotificationToken;

  saveFcmTokenToSharedPref(String value) {
    _sharedPrefOject.setString("fcm_token", value);
  }

  getFcmTokenFromSharedPref() {
    if (_sharedPrefOject.getString("fcm_token") != null) {
      _guestToken = _sharedPrefOject.getString("fcm_token")!;
    }
  }

  void changeFcmToken(String token) {
    _fcmPushNotificationToken = token;
    saveFcmTokenToSharedPref(_fcmPushNotificationToken);
    notifyListeners();
  }

  // USER TOKEN FUNCTIONS
  String getUserToken() => _userToken;

  saveUserTokenToSharedPref(String value) {
    _sharedPrefOject.setString("user_token", value);
  }

  getUserTokenFromSharedPref() {
    if (_sharedPrefOject.getString("user_token") != null) {
      _userToken = _sharedPrefOject.getString("user_token")!;
    }
  }

  void changeUserToken(String token) {
    _userToken = token;
    saveUserTokenToSharedPref(_userToken);
    notifyListeners();
  }

  // USER CODE FUNCTIONS
  String getUserCode() => _userCode;

  saveUserCodeToSharedPref(String value) {
    _sharedPrefOject.setString("user_code", value);
  }

  getUserCodeFromSharedPref() {
    if (_sharedPrefOject.getString("user_code") != null) {
      _userCode = _sharedPrefOject.getString("user_code")!;
    }
  }

  void changeUserCode(String code) {
    _userCode = code;
    saveUserCodeToSharedPref(_userCode);
    notifyListeners();
  }

  // USER NAME FUNCTIONS
  String getUserName() => _userName;

  saveUserNameToSharedPref(String value) {
    _sharedPrefOject.setString("user_name", value);
  }

  getUserNameFromSharedPref() {
    if (_sharedPrefOject.getString("user_name") != null) {
      _userName = _sharedPrefOject.getString("user_name")!;
    }
  }

  void changeUserName(String code) {
    _userName = code;
    saveUserNameToSharedPref(_userName);
    notifyListeners();
  }

  // USER ID FUNCTIONS
  int getUserID() => _userID;

  saveUserIDToSharedPref(int value) {
    _sharedPrefOject.setInt("user_id", value);
  }

  getUserIDFromSharedPref() {
    if (_sharedPrefOject.getInt("user_id") != null) {
      _userID = _sharedPrefOject.getInt("user_id")!;
    }
  }

  void changeUserID(int id) {
    _userID = id;
    saveUserIDToSharedPref(_userID);
    notifyListeners();
  }
}
