class RoomModel {
  String roomId;
  List<String> board; 
  String player1Id;   
  String player2Id;
  String player1Name; // New
  String player2Name; // New
  String turn;        
  String winner;      
  bool isGameActive;
  int player1Score; 
  int player2Score; 
  List<int> winningLine; 

  RoomModel({
    required this.roomId,
    required this.board,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name, // New
    required this.player2Name, // New
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
        'player1Name': player1Name, // New
        'player2Name': player2Name, // New
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
      player1Name: json['player1Name'] ?? 'Player 1', // New
      player2Name: json['player2Name'] ?? 'Player 2', // New
      turn: json['turn'] ?? '',
      winner: json['winner'] ?? '',
      isGameActive: json['isGameActive'] ?? true,
      player1Score: json['player1Score'] ?? 0,
      player2Score: json['player2Score'] ?? 0,
      winningLine: List<int>.from(json['winningLine'] ?? []),
    );
  }
}