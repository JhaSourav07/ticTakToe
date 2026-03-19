import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new Room
  static Future<void> createRoom(RoomModel room) async {
    await _db.collection('rooms').doc(room.roomId).set(room.toJson());
  }

  // Fetch Room Data (Single)
  static Future<RoomModel?> getRoom(String roomId) async {
    DocumentSnapshot doc = await _db.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return RoomModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Join an existing Room
  static Future<bool> joinRoom(String roomId, String playerId, String playerName) async {
    final docRef = _db.collection('rooms').doc(roomId);

    // Transaction prevents two clients from filling the same empty slot
    // at the same time (race condition).
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data();
      if (data == null) return false;

      final room = RoomModel.fromJson(data);

      if (room.player1Id.isEmpty) {
        transaction.update(docRef, {
          'player1Id': playerId,
          'player1Name': playerName,
        });
        return true;
      }

      if (room.player2Id.isEmpty) {
        transaction.update(docRef, {
          'player2Id': playerId,
          'player2Name': playerName,
        });
        return true;
      }

      return false;
    });
  }

  // Reconnect (Force Join/Overwrite a slot)
  static Future<void> reconnect(String roomId, String newPlayerId, String slot) async {
    // slot should be 'player1Id' or 'player2Id'
    await _db.collection('rooms').doc(roomId).update({
      slot: newPlayerId,
    });
  }

  // Leave Room (Clear ID)
  static Future<void> leaveRoom(String roomId, String playerId) async {
    DocumentSnapshot doc = await _db.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      RoomModel room = RoomModel.fromJson(doc.data() as Map<String, dynamic>);
      
      Map<String, dynamic> updates = {};
      if (room.player1Id == playerId) updates['player1Id'] = '';
      if (room.player2Id == playerId) updates['player2Id'] = '';
      
      if (updates.isNotEmpty) {
        await _db.collection('rooms').doc(roomId).update(updates);
      }
    }
  }

  // Listen to Room updates
  static Stream<DocumentSnapshot> roomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  // Update Board Move
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