import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class GameView extends StatelessWidget {
  final String roomId;
  final bool isHost;
  final RoomController controller = Get.find();

  // Updated to use super.key
  GameView({super.key, required this.roomId, required this.isHost});

  @override
  Widget build(BuildContext context) {
    // Wrap in PopScope to handle system back button/gestures
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.exitGame(); // Ensures clean exit state
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Game Room", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => controller.exitGame(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
              onPressed: () => controller.exitGame(),
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A2A40), Color(0xFF1E1E2C)],
            ),
          ),
          child: SafeArea(
            child: Obx(() {
              if (controller.room.value == null) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
              }

              var room = controller.room.value!;
              
              // --- WAITING FOR PLAYER ---
              if (room.player2Id.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 60, width: 60,
                          child: CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF6C63FF)),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Waiting for opponent...",
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Share the code below with your friend",
                          style: TextStyle(fontSize: 14, color: Colors.white38),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: roomId));
                            Get.snackbar("Copied!", "Room code copied", snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20), backgroundColor: Colors.white, colorText: Colors.black);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(roomId, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.white)),
                                const SizedBox(width: 20),
                                const Icon(Icons.copy_rounded, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // --- GAME ACTIVE / FINISHED ---
              bool isMyTurn = room.turn == controller.userId;
              String mySymbol = room.player1Id == controller.userId ? "X" : "O";
              
              String statusText;
              Color statusColor;

              if (room.isGameActive) {
                statusText = isMyTurn ? "YOUR TURN" : "OPPONENT'S TURN";
                statusColor = isMyTurn ? const Color(0xFF4ADE80) : const Color(0xFFFFAB40);
              } else {
                if (room.winner == "Draw") {
                  statusText = "IT'S A DRAW!";
                  statusColor = Colors.white70;
                } else if (room.winner == mySymbol) {
                  statusText = "YOU WON!";
                  statusColor = const Color(0xFF4ADE80);
                } else {
                  statusText = "YOU LOST!";
                  statusColor = const Color(0xFFFF5252);
                }
              }

              return Column(
                children: [
                  // SCOREBOARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text("Player X", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                          Text("${room.player1Score}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ]),
                        Column(children: [
                          const Text("Player O", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                          Text("${room.player2Score}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  
                  // STATUS BAR
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("YOU", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(mySymbol == "X" ? Icons.close_rounded : Icons.circle_outlined, color: mySymbol == "X" ? Colors.cyanAccent : Colors.orangeAccent, size: 20),
                                const SizedBox(width: 8),
                                const Text("Player", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: statusColor.withOpacity(0.5)),
                          ),
                          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // GAME BOARD
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        String cellValue = room.board[index];
                        // Highlight Logic
                        bool isWinningCell = room.winningLine.contains(index);
                        
                        return GestureDetector(
                          onTap: () => controller.makeMove(index, roomId),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              // WINNING COLOR LOGIC
                              color: isWinningCell 
                                  ? (cellValue == "X" ? Colors.cyanAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2))
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isWinningCell 
                                    ? (cellValue == "X" ? Colors.cyanAccent : Colors.orangeAccent)
                                    : (cellValue == "" ? Colors.transparent : (cellValue == "X" ? Colors.cyanAccent.withOpacity(0.3) : Colors.orangeAccent.withOpacity(0.3))),
                                width: isWinningCell ? 3 : 2,
                              ),
                              boxShadow: isWinningCell ? [
                                 BoxShadow(color: (cellValue == "X" ? Colors.cyanAccent : Colors.orangeAccent).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
                              ] : [],
                            ),
                            child: Center(
                              child: cellValue == ""
                                  ? null
                                  : Icon(
                                      cellValue == "X" ? Icons.close_rounded : Icons.circle_outlined,
                                      size: 48,
                                      color: cellValue == "X" ? Colors.cyanAccent : Colors.orangeAccent,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // REMATCH BUTTON
                  if (!room.isGameActive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("PLAY AGAIN", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 10,
                          ),
                          onPressed: () => controller.startRematch(),
                        ),
                      ),
                    ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tag, size: 16, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 4),
                        Text("ROOM ID: $roomId", style: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}