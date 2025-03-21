import 'package:get/get.dart';

class MessagesController extends GetxController {
  final RxInt selectedCategory = 0.obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }
  
  void loadMessages() {
    // In a real app, you would fetch messages from a database or API
    messages.value = [
      MessageModel(
        id: '1',
        name: 'John Smith',
        message: 'Hello, I have a question about the homework.',
        time: '10:30 AM',
        isUnread: true,
        avatarText: 'JS',
      ),
      MessageModel(
        id: '2',
        name: 'Sarah Johnson',
        message: 'Thank you for the feedback on my project.',
        time: 'Yesterday',
        isUnread: false,
        avatarText: 'SJ',
      ),
      MessageModel(
        id: '3',
        name: 'Michael Brown',
        message: 'When is the next class meeting?',
        time: 'Yesterday',
        isUnread: true,
        avatarText: 'MB',
      ),
      MessageModel(
        id: '4',
        name: 'Emily Davis',
        message: 'I\'ve submitted my assignment.',
        time: 'Monday',
        isUnread: false,
        avatarText: 'ED',
      ),
      MessageModel(
        id: '5',
        name: 'David Wilson',
        message: 'Can we schedule a meeting to discuss my grades?',
        time: 'Sunday',
        isUnread: false,
        avatarText: 'DW',
      ),
    ];
  }
  
  List<MessageModel> getFilteredMessages() {
    switch (selectedCategory.value) {
      case 1: // Unread
        return messages.where((message) => message.isUnread).toList();
      case 2: // Important
        return messages.where((message) => message.isImportant).toList();
      default: // All
        return messages;
    }
  }
  
  void markAsRead(String messageId) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index != -1) {
      final message = messages[index];
      message.isUnread = false;
      messages[index] = message;
      messages.refresh();
    }
  }
  
  void toggleImportant(String messageId) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index != -1) {
      final message = messages[index];
      message.isImportant = !message.isImportant;
      messages[index] = message;
      messages.refresh();
    }
  }
}

class MessageModel {
  final String id;
  final String name;
  final String message;
  final String time;
  bool isUnread;
  bool isImportant;
  final String avatarText;
  
  MessageModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isImportant = false,
    required this.avatarText,
  });
}
