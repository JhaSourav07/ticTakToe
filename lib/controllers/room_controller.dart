import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ticktaktoe/views/game_view.dart';
import '../models/room_model.dart';
import '../services/database_service.dart';

class RoomController extends GetxController {
  final String userId = DateTime.now().millisecondsSinceEpoch.toString();
  
  // New Controller for Name Input
  final TextEditingController nameController = TextEditingController();
  
  Rx<RoomModel?> room = Rx<RoomModel?>(null);
  
  void createRoom() async {
    try {
      if (nameController.text.isEmpty) {
        Get.snackbar("Required", "Please enter your nickname");
        return;
      }

      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String newRoomId = (1000 + Random().nextInt(9000)).toString(); 
      String myName = nameController.text.trim();

      RoomModel newRoom = RoomModel(
        roomId: newRoomId,
        board: List.filled(9, ''),
        player1Id: userId,
        player2Id: '',
        player1Name: myName, // Set Host Name
        player2Name: '',
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

  void joinRoom(String roomId) async {
    try {
       if (nameController.text.isEmpty) {
        Get.snackbar("Required", "Please enter your nickname");
        return;
      }

      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String myName = nameController.text.trim();
      
      // Pass name to joinRoom
      bool joined = await DatabaseService.joinRoom(roomId, userId, myName);
      
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
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var win in wins) {
      String a = board[win[0]];
      String b = board[win[1]];
      String c = board[win[2]];

      if (a != '' && a == b && a == c) {
        int p1Score = room.value!.player1Score;
        int p2Score = room.value!.player2Score;
        
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
    String currentP1Name = room.value!.player1Name;
    String currentP2Name = room.value!.player2Name;
    int currentP1Score = room.value!.player1Score;
    int currentP2Score = room.value!.player2Score;

    // Swap players AND names AND scores
    Map<String, dynamic> data = {
      'board': List.filled(9, ''),
      'player1Id': currentP2, 
      'player2Id': currentP1,
      'player1Name': currentP2Name,
      'player2Name': currentP1Name,
      'player1Score': currentP2Score, // Correctly swap scores
      'player2Score': currentP1Score,
      'turn': currentP2, 
      'winner': '',
      'isGameActive': true,
      'winningLine': [],
    };

    DatabaseService.restartGame(room.value!.roomId, data);
  }

  void exitGame() {
    room.value = null;
    Get.back();
  }
}