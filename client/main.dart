import 'dart:html';

import 'ChatManager.dart';
import 'CommunicationManager.dart';

void main() {
    CommunicationManager    comManager;
    ChatManager             chatManager;

    comManager = new CommunicationManager('ws://localhost:1337');
    chatManager = new ChatManager(comManager);

    chatManager.run();
}
