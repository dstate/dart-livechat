import 'dart:html';
import 'dart:async';

import 'Protocol.dart' as Protocol;
import 'CommunicationManager.dart';
import 'ChatState.dart';
import 'UsersManager.dart';
import 'User.dart';
import 'MessagesManager.dart';
import 'Message.dart';

class ChatManager {
    CommunicationManager    comManager;
    UsersManager            usersManager;
    MessagesManager         msgManager;
    User                    user;
    num                     state;


    ChatManager(CommunicationManager comManager) {
        this.comManager = comManager;
        this.usersManager = new UsersManager(querySelector('#users-section'));
        this.msgManager = new MessagesManager(querySelector('#messages-section'));
        this.user = new User();
        this.state = ChatState.IDLE;
    }

    void run() {
        this.comManager.listenForAction(Protocol.Action.STATUS, this.statusListener);
        this.comManager.listenForAction(Protocol.Action.USER_LIST, this.userListListener);
        this.comManager.listenForAction(Protocol.Action.USER_JOIN, this.userJoinListener);
        this.comManager.listenForAction(Protocol.Action.USER_QUITS, this.userQuitsListener);
        this.comManager.listenForAction(Protocol.Action.RECEIVE_MESSAGE, this.receiveMessageListener);

        InputElement inputSetNick = querySelector('#inputSetNick');
        inputSetNick.focus();
        inputSetNick.onKeyUp.listen((KeyboardEvent e) {
            KeyEvent ke = new KeyEvent.wrap(e);
            if (ke.keyCode == KeyCode.ENTER)
                this.setNicknameCallback(inputSetNick.value);
        });

        ButtonElement btnSetNick = querySelector('#btnSetNick');
        btnSetNick.onClick.listen((Event e) => this.setNicknameCallback(inputSetNick.value));

        TextAreaElement inputMessage = querySelector('#inputMessage');
        inputMessage.onKeyPress.listen((KeyboardEvent e) {
            KeyEvent ke = new KeyEvent.wrap(e);
            if (ke.keyCode == KeyCode.ENTER) {
                e.preventDefault();
                this.comManager.sendMessageRequest(inputMessage.value);
                inputMessage.value = '';
            }
        });

        DivElement chatBox = querySelector('#chat-box');
        chatBox.hidden = true;

        this.state = ChatState.IDLE;
    }

    void logForUser(String msg) {
        if (this.state == ChatState.CONNECTED) {
            UListElement list = querySelector('#messages-section');
            LIElement el = new LIElement();
            el.text = msg;
            list.children.add(el);
        } else {
            TableSectionElement connexionStatus = querySelector('#connexionStatus');
            connexionStatus.text = msg;
        }
    }

    void displayChat() {
        DivElement loginBox = querySelector('#login-box');
        loginBox.hidden = true;
        DivElement chatBox = querySelector('#chat-box');
        chatBox.hidden = false;

        TextAreaElement inputMessage = querySelector('#inputMessage');
        inputMessage.focus();

        this.comManager.userListRequest();
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
                this.displayChat();
            }
        }
    }

    void userListListener(Map data) {
        List<String> usersStrList = data['users'];
        List<User> usersList = [];

        usersList.add(this.user);
        usersStrList.forEach((String nickname) {
            if (nickname != this.user.getNickname())
                usersList.add(new User(nickname));
        });
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

    void receiveMessageListener(Map data) {
        User sender = this.usersManager.getUserByNickname(data['nickname']);
        Message msg = new Message(sender, data['message']);
        this.msgManager.addMessage(msg);
    }
}
