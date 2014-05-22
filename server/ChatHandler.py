import tornado.websocket
import json

import Protocol
from User import User

class ChatHandler(tornado.websocket.WebSocketHandler):
    users = []

    def open(self):
        self.user = User()
        ChatHandler.users.append(self.user)

    def on_message(self, message):
        ret = self.manage_message(message)
        if ret != Protocol.Status.NONE:
            data = {'code': ret}
            packet = self.make_packet(Protocol.Action.STATUS, data)
            self.write_message(packet)

    def on_close(self):
        ChatHandler.users.remove(self.user)

    def make_packet(self, action, data):
        packet = {'action': action, 'data': data}
        return json.dumps(packet)

    def manage_message(self, message):
        try:
            json_result = json.loads(message)
            if json_result['action'] == Protocol.Action.SET_NICKNAME:
                self.set_nickname(json_result['data'])
                return Protocol.Status.SUCCESS_NICKNAME_SET
        except (ValueError, KeyError):
            print '[EXCEPTION] Bad json: "' + message + '".'
            return Protocol.Status.ERROR_BAD_JSON

    def set_nickname(self, data):
        self.user.nickname = data['nickname']
        print 'Set nickname success, ' + self.user.nickname;
