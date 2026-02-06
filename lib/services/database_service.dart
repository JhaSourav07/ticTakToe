import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createRoom(RoomModel room) async {
    await _db.collection('rooms').doc(room.roomId).set(room.toJson());
  }

  // Updated to accept playerName
  static Future<bool> joinRoom(String roomId, String playerId, String playerName) async {
    DocumentSnapshot doc = await _db.collection('rooms').doc(roomId).get();

    if (doc.exists) {
      RoomModel room = RoomModel.fromJson(doc.data() as Map<String, dynamic>);
      
      if (room.player2Id.isEmpty) {
        await _db.collection('rooms').doc(roomId).update({
          'player2Id': playerId,
          'player2Name': playerName, // Save name
        });
        return true;
      }
    }
    return false;
  }

  static Stream<DocumentSnapshot> roomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  static Future<void> updateGame(String roomId, List<String> board, String nextTurn) async {
    await _db.collection('rooms').doc(roomId).update({
      'board': board,
      'turn': nextTurn,
    });
  }

  static Future<void> setWinner(String roomId, String winner, int p1Score, int p2Score, List<int> winningLine) async {
    await _db.collection('rooms').doc(roomId).update({
      'winner': winner,
      'isGameActive': false,
      'player1Score': p1Score,
      'player2Score': p2Score,
      'winningLine': winningLine,
    });
  }

  static Future<void> restartGame(String roomId, Map<String, dynamic> data) async {
    await _db.collection('rooms').doc(roomId).update(data);
  }
}