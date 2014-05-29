import 'dart:html';
import 'dart:convert';

import 'Protocol.dart' as Protocol;

class CommunicationManager {
    WebSocket                   ws;
    Map<num, List<Function>>    actionCallbacks;

    CommunicationManager(String url) {
        this.ws = new WebSocket(url);
        this.actionCallbacks = new Map();

        this.ws.onMessage.listen((MessageEvent e) => this.onMessageListener(e));
    }

    String makePacket(num action, Map data) {
        Map<num, Map> packet = {'action': action, 'data': data};
        return JSON.encode(packet);
    }

    bool sendData(String data) {
        if (this.ws != null && this.ws.readyState == WebSocket.OPEN) {
            this.ws.send(data);
            return true;
        }
        return false;
    }

    void onMessageListener(MessageEvent e) {
        Map data = JSON.decode(e.data);

        this.actionCallbacks.forEach((num action, List<Function> callbackList) {
            if (data['action'] == action)
                callbackList.forEach((Function callback) => callback(data['data']));
        });
    }

    void listenForAction(num action, Function callback) {
        if (!this.actionCallbacks.containsKey(action))
            this.actionCallbacks[action] = new List<Function>();
        this.actionCallbacks[action].add(callback);
    }

    bool setNicknameRequest(String nickname) {
        Map data = {'nickname': nickname};
        String jsonPacket = this.makePacket(Protocol.Action.SET_NICKNAME, data);
        return this.sendData(jsonPacket);
    }

    bool userListRequest() {
        String jsonPacket = this.makePacket(Protocol.Action.USER_LIST, {});
        return this.sendData(jsonPacket);
    }
}
