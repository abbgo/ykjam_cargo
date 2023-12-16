import 'package:flutter/material.dart';

class ChatData {
  String id, userID, adminID, message, src, time, type, readed;
  IconData icon;

  ChatData(this.id, this.userID, this.adminID, this.message, this.src,
      this.time, this.type, this.readed, this.icon);
}
