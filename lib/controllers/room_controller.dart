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
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String newRoomId = (1000 + Random().nextInt(9000)).toString(); // Generates 4-digit code
      
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
      
      // Close loading
      if (Get.isDialogOpen!) Get.back();

      // Start listening to the room
      streamRoom(newRoomId);
      Get.to(() => GameView(roomId: newRoomId, isHost: true));

    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        "Error Creating Room", 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print("Firebase Error: $e");
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
      Get.snackbar(
        "Connection Error", 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      print("Firebase Error: $e");
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
    
    // Check if it's my turn
    if (room.value!.turn != userId) {
      Get.snackbar("Wait", "It's not your turn!");
      return;
    }
    // Check if cell is empty
    if (room.value!.board[index] != '') return;
    // Check if game is active
    if (!room.value!.isGameActive) return;

    // Logic for X and O
    String mySymbol = (room.value!.player1Id == userId) ? "X" : "O";
    List<String> newBoard = List.from(room.value!.board);
    newBoard[index] = mySymbol;

    // Determine next turn
    String nextPlayerId = (room.value!.player1Id == userId) 
        ? room.value!.player2Id 
        : room.value!.player1Id;

    // Update Firebase
    try {
      DatabaseService.updateGame(roomId, newBoard, nextPlayerId);
      // Check for win locally for immediate feedback
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
        Get.snackbar("Game Over", "$a Wins!");
        return;
      }
    }

    if (!board.contains('')) {
      DatabaseService.setWinner(roomId, "Draw");
      Get.snackbar("Game Over", "It's a Draw!");
    }
  }
}