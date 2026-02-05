class RoomModel {
  String roomId;
  List<String> board; 
  String player1Id;   
  String player2Id;   
  String turn;        
  String winner;      
  bool isGameActive;
  int player1Score; // New: Score for X
  int player2Score; // New: Score for O
  List<int> winningLine; // New: Indices of winning cells (e.g., [0,1,2])

  RoomModel({
    required this.roomId,
    required this.board,
    required this.player1Id,
    required this.player2Id,
    required this.turn,
    required this.winner,
    required this.isGameActive,
    this.player1Score = 0,
    this.player2Score = 0,
    this.winningLine = const [],
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'board': board,
        'player1Id': player1Id,
        'player2Id': player2Id,
        'turn': turn,
        'winner': winner,
        'isGameActive': isGameActive,
        'player1Score': player1Score,
        'player2Score': player2Score,
        'winningLine': winningLine,
      };

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] ?? '',
      board: List<String>.from(json['board'] ?? List.filled(9, '')),
      player1Id: json['player1Id'] ?? '',
      player2Id: json['player2Id'] ?? '',
      turn: json['turn'] ?? '',
      winner: json['winner'] ?? '',
      isGameActive: json['isGameActive'] ?? true,
      player1Score: json['player1Score'] ?? 0,
      player2Score: json['player2Score'] ?? 0,
      winningLine: List<int>.from(json['winningLine'] ?? []),
    );
  }
}