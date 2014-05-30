import 'dart:html';

import 'Message.dart';

class MessagesManager {
    UListElement    list;
    List<Message>   messages;

    MessagesManager(UListElement list) {
        this.list = list;
        this.messages = [];
    }

    List<Message> getMessages() {
        return this.messages;
    }

    void addMessage(Message m) {
        LIElement newMessage = new LIElement();
        newMessage.text = m.getSender().getNickname() + ': ' + m.getText();
        this.list.children.add(newMessage);
    }
}
