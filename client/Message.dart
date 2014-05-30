import 'User.dart';

class Message {
    User        sender;
    String      text;
    DateTime    timestamp;

    Message(User sender, String text) {
        this.sender = sender;
        this.text = text;
        this.timestamp = new DateTime.now();
    }

    User getSender() {
        return this.sender;
    }

    String getText() {
        return this.text;
    }

    DateTime getTimestamp() {
        return this.timestamp;
    }
}
