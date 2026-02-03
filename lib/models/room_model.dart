class RoomModel {
  String roomId;
  List<String> board; // The 9 grids, e.g., ["", "X", "", ...]
  String player1Id;   // Creator ID
  String player2Id;   // Joiner ID
  String turn;        // ID of player whose turn it is
  String winner;      // "", "X", "O", or "Draw"
  bool isGameActive;

  RoomModel({
    required this.roomId,
    required this.board,
    required this.player1Id,
    required this.player2Id,
    required this.turn,
    required this.winner,
    required this.isGameActive,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'board': board,
        'player1Id': player1Id,
        'player2Id': player2Id,
        'turn': turn,
        'winner': winner,
        'isGameActive': isGameActive,
      };

  // Create from Firebase Snapshot
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] ?? '',
      board: List<String>.from(json['board'] ?? List.filled(9, '')),
      player1Id: json['player1Id'] ?? '',
      player2Id: json['player2Id'] ?? '',
      turn: json['turn'] ?? '',
      winner: json['winner'] ?? '',
      isGameActive: json['isGameActive'] ?? true,
    );
  }
}