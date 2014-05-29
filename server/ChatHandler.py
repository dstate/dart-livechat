import tornado.websocket
import json

import Protocol
from User import User

class ChatHandler(tornado.websocket.WebSocketHandler):
    active_users = []
    opened_connexions = []

    def open(self):
        self.user = User()
        ChatHandler.opened_connexions.append(self)

    def on_message(self, message):
        ret = self.manage_message(message)
        if ret != Protocol.Status.NONE:
            data = {'code': ret}
            packet = self.make_packet(Protocol.Action.STATUS, data)
            self.write_message(packet)

    def on_close(self):
        self.opened_connexions.remove(self)
        if len(self.user.nickname) > 0:
            packet = self.user_quits()
            self.broadcast_packet(packet)

    def make_packet(self, action, data):
        packet = {'action': action, 'data': data}
        return json.dumps(packet)

    def broadcast_packet(self, packet):
        for co in ChatHandler.opened_connexions:
            co.write_message(packet)

    def manage_message(self, message):
        try:
            json_result = json.loads(message)
            if json_result['action'] == Protocol.Action.SET_NICKNAME:
                self.set_nickname(json_result['data'])
                packet = self.user_join()
                self.broadcast_packet(packet)
                return Protocol.Status.SUCCESS_NICKNAME_SET
            elif json_result['action'] == Protocol.Action.USER_LIST:
                packet = self.make_packet(Protocol.Action.USER_LIST, {'users': self.user_list()})
                self.write_message(packet)
                return Protocol.Status.NONE
        except (ValueError, KeyError):
            print '[EXCEPTION] Bad json: "' + message + '".'
            return Protocol.Status.ERROR_BAD_JSON

    def set_nickname(self, data):
        self.user.nickname = data['nickname']
        print '[SUCCESS] Set nickname to ' + self.user.nickname;

    def user_list(self):
        user_list = []
        for user in ChatHandler.active_users:
            user_list.append(user.nickname)
        print '[SUCCESS] User list'
        return user_list

    def user_join(self):
        ChatHandler.active_users.append(self.user)
        packet = self.make_packet(Protocol.Action.USER_JOIN, {'nickname': self.user.nickname})
        return packet

    def user_quits(self):
        ChatHandler.active_users.remove(self.user)
        packet = self.make_packet(Protocol.Action.USER_QUITS, {'nickname': self.user.nickname})
        return packet
