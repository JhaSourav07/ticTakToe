import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ticktaktoe/views/game_view.dart';
import '../models/room_model.dart';
import '../services/database_service.dart';

class RoomController extends GetxController {
  // Current User ID (Simple random generation for demo)
  final String userId = DateTime.now().millisecondsSinceEpoch.toString();
  
  Rx<RoomModel?> room = Rx<RoomModel?>(null);
  
  // Create Party
  void createRoom() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String newRoomId = (1000 + Random().nextInt(9000)).toString(); 
      
      RoomModel newRoom = RoomModel(
        roomId: newRoomId,
        board: List.filled(9, ''),
        player1Id: userId,
        player2Id: '',
        turn: userId, // Creator moves first
        winner: '',
        isGameActive: true,
      );

      await DatabaseService.createRoom(newRoom);
      
      if (Get.isDialogOpen!) Get.back();

      streamRoom(newRoomId);
      Get.to(() => GameView(roomId: newRoomId, isHost: true));

    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // Join Party
  void joinRoom(String roomId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      bool joined = await DatabaseService.joinRoom(roomId, userId);
      
      if (Get.isDialogOpen!) Get.back();

      if (joined) {
        streamRoom(roomId);
        Get.to(() => GameView(roomId: roomId, isHost: false));
      } else {
        Get.snackbar("Error", "Room is full or does not exist");
      }
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // Listen to Firebase
  void streamRoom(String roomId) {
    room.bindStream(DatabaseService.roomStream(roomId).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RoomModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    }));
  }

  // Handle a player tap
  void makeMove(int index, String roomId) {
    if (room.value == null) return;
    
    if (room.value!.turn != userId) {
      Get.snackbar("Wait", "It's not your turn!");
      return;
    }
    if (room.value!.board[index] != '') return;
    if (!room.value!.isGameActive) return;

    String mySymbol = (room.value!.player1Id == userId) ? "X" : "O";
    List<String> newBoard = List.from(room.value!.board);
    newBoard[index] = mySymbol;

    String nextPlayerId = (room.value!.player1Id == userId) 
        ? room.value!.player2Id 
        : room.value!.player1Id;

    try {
      DatabaseService.updateGame(roomId, newBoard, nextPlayerId);
      checkWinner(newBoard, roomId);
    } catch (e) {
      Get.snackbar("Sync Error", "Could not update move");
    }
  }

  void checkWinner(List<String> board, String roomId) {
    List<List<int>> wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var win in wins) {
      String a = board[win[0]];
      String b = board[win[1]];
      String c = board[win[2]];

      if (a != '' && a == b && a == c) {
        DatabaseService.setWinner(roomId, a);
        return;
      }
    }

    if (!board.contains('')) {
      DatabaseService.setWinner(roomId, "Draw");
    }
  }

  // Start Rematch
  void startRematch(String choice) {
    if (room.value == null) return;
    
    // Identify opponent ID
    String opponentId = (room.value!.player1Id == userId) 
        ? room.value!.player2Id 
        : room.value!.player1Id;

    String newP1, newP2;
    
    // If I chose X, I become Player 1. If O, I become Player 2.
    if (choice == 'X') {
      newP1 = userId;
      newP2 = opponentId;
    } else {
      newP1 = opponentId;
      newP2 = userId;
    }

    // Reset Data
    Map<String, dynamic> data = {
      'board': List.filled(9, ''),
      'player1Id': newP1,
      'player2Id': newP2,
      'turn': newP1, // X always starts
      'winner': '',
      'isGameActive': true,
    };

    DatabaseService.restartGame(room.value!.roomId, data);
    if (Get.isDialogOpen!) Get.back();
  }
}