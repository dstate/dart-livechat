import 'dart:html';
import 'dart:async';

import 'Protocol.dart' as Protocol;
import 'CommunicationManager.dart';
import 'ChatState.dart';
import 'UsersManager.dart';
import 'User.dart';

class ChatManager {
    CommunicationManager    comManager;
    UsersManager            usersManager;
    User                    user;
    num                     state;


    ChatManager(CommunicationManager comManager) {
        this.comManager = comManager;
        this.usersManager = new UsersManager(querySelector('#users-section'));
        this.user = new User();
        this.state = ChatState.IDLE;
    }

    void run() {
        this.comManager.listenForAction(Protocol.Action.STATUS, this.statusListener);
        this.comManager.listenForAction(Protocol.Action.USER_LIST, this.userListListener);
        this.comManager.listenForAction(Protocol.Action.USER_JOIN, this.userJoinListener);
        this.comManager.listenForAction(Protocol.Action.USER_QUITS, this.userQuitsListener);

        InputElement inputSetNick = querySelector('#inputSetNick');
        ButtonElement btnSetNick = querySelector('#btnSetNick');
        btnSetNick.onClick.listen((Event e) => this.setNicknameCallback(inputSetNick.value));

        DivElement chatBox = querySelector('#chat-box');
        chatBox.hidden = true;

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
                this.user.setNickname(nickname);
                Timer timer = new Timer(new Duration(seconds: 5), () {
                    if (this.state == ChatState.WAITING_NICKNAME_FROM_SERVER) {
                        this.logForUser('Connection timed out. Try again.');
                        this.state = ChatState.IDLE;
                        this.user.setNickname('');
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
                this.user.setNickname('');
            } else if (data['code'] == Protocol.Status.ERROR_BAD_NICKNAME) {
                this.logForUser('Invalid nickname.');
                this.state = ChatState.IDLE;
                this.user.setNickname('');
            } else if (data['code'] == Protocol.Status.ERROR_NICKNAME_TAKEN) {
                this.logForUser('Nickname already in use.');
                this.state = ChatState.IDLE;
                this.user.setNickname('');
            } else if (data['code'] == Protocol.Status.SUCCESS_NICKNAME_SET) {
                this.logForUser('Success!');
                this.state = ChatState.CONNECTED;

                DivElement loginBox = querySelector('#login-box');
                loginBox.hidden = true;
                DivElement chatBox = querySelector('#chat-box');
                chatBox.hidden = false;

                this.comManager.userListRequest();
            }
        }
    }

    void userListListener(Map data) {
        List<String> usersStrList = data['users'];
        List<User> usersList = [];

        usersStrList.forEach((String nickname) => usersList.add(new User(nickname)));
        this.usersManager.setUsers(usersList);
    }

    void userJoinListener(Map data) {
        User newUser = new User(data['nickname']);

        if (newUser != this.user)
            this.usersManager.addUser(newUser);
    }

    void userQuitsListener(Map data) {
        User u = new User(data['nickname']);

        this.usersManager.removeUser(u);
    }
}
