import 'dart:async';
import 'dart:convert';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/model/home.dart';

class HomeRepository {
  HomeRepository(FileStorage fileStorage) :
    assert(fileStorage != null),
    _fileStorage = fileStorage;
  
  FileStorage _fileStorage;
  final filename = "home.json";

  Future<HomeScreen> getHomeScreen() async {
    String contentString = await _fileStorage.getContent(filename);
    if (contentString?.isEmpty ?? true) {
      return HomeScreen.withDefault();
    } 
    var map = json.decode(contentString);
    var homeScreen = HomeScreen.fromJson(map);
    return homeScreen;
  }

  Future<bool> updateHomeScreen(HomeScreen homeScreen) async {
    String stringified = json.encode(homeScreen);
    return await _fileStorage.writeContent(filename, stringified);
  }
}