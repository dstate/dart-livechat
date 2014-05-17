import tornado.websocket
import json

from User import User

class ChatHandler(tornado.websocket.WebSocketHandler):
    users = []

    def open(self):
        self.user = User()
        ChatHandler.users.append(self.user)

    def on_message(self, message):
        self.manage_message(message)

    def on_close(self):
        ChatHandler.users.remove(self.user)

    def manage_message(self, message):
        try:
            json_result = json.loads(message)
            if json_result['action'] == 0:
                self.set_nickname(json_result['data'])
            return True
        except (ValueError, KeyError):
            print '[EXCEPTION] Bad json: "' + message + '".'
            return False

    def set_nickname(self, data):
        self.user.nickname = data['nickname']
