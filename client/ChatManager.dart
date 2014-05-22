import 'dart:html';
import 'dart:async';

import 'Protocol.dart' as Protocol;
import 'CommunicationManager.dart';
import 'ChatState.dart';

class ChatManager {
    CommunicationManager    comManager;
    InputElement            inputSetNick;
    ButtonElement           btnSetNick;
    num                     state;

    ChatManager(CommunicationManager comManager) {
        this.comManager = comManager;
        this.inputSetNick = querySelector('#inputSetNick');
        this.btnSetNick = querySelector('#btnSetNick');
        this.state = ChatState.IDLE;
    }

    void run() {
        this.comManager.listenForAction(Protocol.Action.STATUS, this.statusListener);
        this.btnSetNick.onClick.listen((Event e) => this.setNicknameCallback(this.inputSetNick.value));
        this.state = ChatState.IDLE;
    }

    void logForUser(String msg) {
        TableSectionElement connexionStatus = querySelector('#connexionStatus');
        connexionStatus.text = msg;
    }

    void setNicknameCallback(String nickname) {
        if (this.state == ChatState.IDLE) {
            if (!this.comManager.setNicknameRequest(nickname)) {
                this.logForUser('Fail.');
            } else {
                this.logForUser('Awaiting server...');
                this.state = ChatState.WAITING_NICKNAME_FROM_SERVER;
                Timer timer = new Timer(new Duration(seconds: 5), () {
                    if (this.state == ChatState.WAITING_NICKNAME_FROM_SERVER) {
                        this.logForUser('Connection timed out. Try again.');
                        this.state = ChatState.IDLE;
                    }
                });
            }
        }
    }

    void statusListener(Map data) {
        if (this.state == ChatState.WAITING_NICKNAME_FROM_SERVER) {
            if (data['code'] == Protocol.Status.ERROR_BAD_JSON) {
                this.logForUser('Couldn\'t connect. Try again.');
                this.state = ChatState.IDLE;
            } else if (data['code'] == Protocol.Status.ERROR_BAD_NICKNAME) {
                this.logForUser('Invalid nickname.');
                this.state = ChatState.IDLE;
            } else if (data['code'] == Protocol.Status.ERROR_NICKNAME_TAKEN) {
                this.logForUser('Nickname already in use.');
                this.state = ChatState.IDLE;
            } else if (data['code'] == Protocol.Status.SUCCESS_NICKNAME_SET) {
                this.logForUser('Success!');
                this.state = ChatState.CONNECTED;
            }
        }
    }
}
