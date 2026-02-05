import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ticktaktoe/views/game_view.dart';
import '../models/room_model.dart';
import '../services/database_service.dart';

class RoomController extends GetxController {
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
        turn: userId,
        winner: '',
        isGameActive: true,
        player1Score: 0,
        player2Score: 0,
        winningLine: [],
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

  void streamRoom(String roomId) {
    room.bindStream(DatabaseService.roomStream(roomId).map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RoomModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    }));
  }

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
        // Calculate new scores
        int p1Score = room.value!.player1Score;
        int p2Score = room.value!.player2Score;
        
        // P1 is always X, P2 is always O
        if (a == 'X') {
          p1Score++;
        } else {
          p2Score++;
        }

        DatabaseService.setWinner(roomId, a, p1Score, p2Score, win);
        return;
      }
    }

    if (!board.contains('')) {
      DatabaseService.setWinner(roomId, "Draw", room.value!.player1Score, room.value!.player2Score, []);
    }
  }

  void startRematch() {
    if (room.value == null) return;
    
    String currentP1 = room.value!.player1Id;
    String currentP2 = room.value!.player2Id;

    // Keep scores, swap players
    // Note: Scores are tied to X/O (P1/P2). 
    // If we swap players, the scores technically "swap" owners if we don't adjust logic.
    // For simplicity: We keep P1 as P1 score (X score) and P2 as P2 score (O score).
    // The players physically swap roles, so the score for "X" continues to accumulate.

    Map<String, dynamic> data = {
      'board': List.filled(9, ''),
      'player1Id': currentP2, 
      'player2Id': currentP1,
      'turn': currentP2, 
      'winner': '',
      'isGameActive': true,
      'winningLine': [], // Reset winning line
    };

    DatabaseService.restartGame(room.value!.roomId, data);
  }

  void exitGame() {
    room.value = null; // Clear local state
    Get.back(); // Go home
  }
}