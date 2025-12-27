class TransactionModel {
  final int id;
  final String senderId;
  final String receiverId;
  final int amount; // Stored as integer (Paise)
  final String type;
  final String description;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}
