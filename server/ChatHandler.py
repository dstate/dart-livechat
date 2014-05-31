import tornado.websocket
import json
import threading
import time

import Protocol
from User import User

class ChatHandler(tornado.websocket.WebSocketHandler):
    active_users = []
    opened_connexions = []

    def open(self):
        self.user = User()
        self.last_live = time.time()
        self.connected = True
        ChatHandler.opened_connexions.append(self)
        threading.Timer(1, self.manage_live).start()

    def on_message(self, message):
        if self.connected:
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
            print self.user.nickname + ' left.';

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
            elif json_result['action'] == Protocol.Action.SEND_MESSAGE:
                packet = self.make_packet(Protocol.Action.RECEIVE_MESSAGE,
                        {'nickname': self.user.nickname, 'message': json_result['data']['message']})
                self.broadcast_packet(packet)
                print self.user.nickname + ': ' + json_result['data']['message']
                return Protocol.Status.NONE
            elif json_result['action'] == Protocol.Action.LIVE:
                self.last_live = time.time()
        except (ValueError, KeyError):
            print '[EXCEPTION] Bad json: "' + message + '".'
            return Protocol.Status.ERROR_BAD_JSON

    def set_nickname(self, data):
        self.user.nickname = data['nickname']
        print self.user.nickname + ' joined.';

    def user_list(self):
        user_list = []
        for user in ChatHandler.active_users:
            user_list.append(user.nickname)
        return user_list

    def user_join(self):
        ChatHandler.active_users.append(self.user)
        packet = self.make_packet(Protocol.Action.USER_JOIN, {'nickname': self.user.nickname})
        return packet

    def user_quits(self):
        ChatHandler.active_users.remove(self.user)
        packet = self.make_packet(Protocol.Action.USER_QUITS, {'nickname': self.user.nickname})
        return packet

    def manage_live(self):
        if time.time() - self.last_live > 5:
            self.connected = False;
            if len(self.user.nickname) > 0:
                print self.user.nickname + ' timed out.'
        else:
            threading.Timer(1, self.manage_live).start()
            packet = self.make_packet(Protocol.Action.LIVE, {})
            self.write_message(packet)

