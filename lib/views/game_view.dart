import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

// --- HOME VIEW ---
class HomeView extends StatelessWidget {
  final RoomController controller = Get.put(RoomController());
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multiplayer Tic-Tac-Toe")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => controller.createRoom(),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              child: const Text("Create Party"),
            ),
            const SizedBox(height: 20),
            const Text("OR"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter 4-Digit Code",
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  controller.joinRoom(codeController.text);
                }
              },
              child: const Text("Join Party"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- GAME VIEW ---
class GameView extends StatelessWidget {
  final String roomId;
  final bool isHost;
  final RoomController controller = Get.find();

  GameView({required this.roomId, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room Code: $roomId")),
      body: Obx(() {
        if (controller.room.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        var room = controller.room.value!;
        
        // Wait for opponent
        if (room.player2Id.isEmpty) {
          return const Center(child: Text("Waiting for player to join..."));
        }

        bool isMyTurn = room.turn == controller.userId;
        String status = isMyTurn ? "Your Turn" : "Opponent's Turn";
        if (!room.isGameActive) status = "Winner: ${room.winner}";

        return Column(
          children: [
            const SizedBox(height: 20),
            Text(status, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => controller.makeMove(index, roomId),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Center(
                        child: Text(
                          room.board[index],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: room.board[index] == "X" ? Colors.blue : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}