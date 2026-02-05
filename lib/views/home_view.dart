
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticktaktoe/controllers/room_controller.dart';

class HomeView extends StatelessWidget {
  final RoomController controller = Get.find<RoomController>();
  final TextEditingController codeController = TextEditingController();

  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A40), Color(0xFF1E1E2C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.videogame_asset_outlined,
                      size: 60,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "TIC TAC TOE",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "MULTIPLAYER",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Game Menu Card
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        // Create Room Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.createRoom(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text(
                              "CREATE PARTY",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Join Input
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "ENTER CODE",
                            hintStyle: TextStyle(fontSize: 14, letterSpacing: 1),
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                            prefixIcon: Icon(Icons.keyboard, color: Colors.white30),
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Join Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (codeController.text.isNotEmpty) {
                                controller.joinRoom(codeController.text);
                              }
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text(
                              "JOIN PARTY",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.5), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
