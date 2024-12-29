import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:music_app/data/repository/repository.dart';

import '../../data/model/song.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  Future<void> loadSongs() async {
    final repository = DefaultRepository();
    try {
      // Đợi dữ liệu từ repository và thêm vào songStream nếu có dữ liệu
      final songs = await repository.loadData();
      if (songs != null) {
        songStream.add(songs);
      }
    } catch (e) {
      // Xử lý lỗi nếu có, ví dụ: log lỗi hoặc thông báo
      print('Error loading songs: $e');
    }
  }
}