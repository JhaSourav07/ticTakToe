import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ticktaktoe/views/game_view.dart';
import '../models/room_model.dart';
import '../services/database_service.dart';

class RoomController extends GetxController {
  final String userId = DateTime.now().millisecondsSinceEpoch.toString();
  
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
        player1Name: myName,
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

      // 1. Check Room State first
      RoomModel? existingRoom = await DatabaseService.getRoom(roomId);
      
      if (existingRoom == null) {
        if (Get.isDialogOpen!) Get.back();
        Get.snackbar("Error", "Room does not exist");
        return;
      }

      // 2. Logic to Handle Join vs Rejoin
      bool isFull = existingRoom.player1Id.isNotEmpty && existingRoom.player2Id.isNotEmpty;
      
      if (isFull) {
        if (Get.isDialogOpen!) Get.back();
        // Show Rejoin Dialog
        Get.defaultDialog(
          title: "Room Full",
          content: Column(
            children: [
              const Text("Did you get disconnected? Select your name to reconnect:"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _reconnect(roomId, 'player1Id');
                },
                child: Text("I am ${existingRoom.player1Name}"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _reconnect(roomId, 'player2Id');
                },
                child: Text("I am ${existingRoom.player2Name}"),
              ),
            ],
          ),
        );
      } else {
        // Normal Join (or filling an empty slot if someone left)
        bool joined = await DatabaseService.joinRoom(roomId, userId, nameController.text.trim());
        if (Get.isDialogOpen!) Get.back();

        if (joined) {
          streamRoom(roomId);
          Get.to(() => GameView(roomId: roomId, isHost: false));
        } else {
          Get.snackbar("Error", "Could not join room");
        }
      }

    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  void _reconnect(String roomId, String slot) async {
    Get.back(); // Close Dialog
    await DatabaseService.reconnect(roomId, userId, slot);
    streamRoom(roomId);
    Get.to(() => GameView(roomId: roomId, isHost: false));
    Get.snackbar("Success", "Reconnected to game!");
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

    // Determine Symbol based on Player ID
    String mySymbol = (room.value!.player1Id == userId) ? "X" : "O";
    List<String> newBoard = List.from(room.value!.board);
    newBoard[index] = mySymbol;

    // Check if other player exists before passing turn
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

    Map<String, dynamic> data = {
      'board': List.filled(9, ''),
      'player1Id': currentP2, 
      'player2Id': currentP1,
      'player1Name': currentP2Name,
      'player2Name': currentP1Name,
      'player1Score': currentP2Score, 
      'player2Score': currentP1Score,
      'turn': currentP2, 
      'winner': '',
      'isGameActive': true,
      'winningLine': [],
    };

    DatabaseService.restartGame(room.value!.roomId, data);
  }

  void exitGame() {
    if (room.value != null) {
      // Notify DB that I am leaving
      DatabaseService.leaveRoom(room.value!.roomId, userId);
    }
    room.value = null;
    Get.back();
  }
}