import tornado.ioloop
import tornado.web
import tornado.websocket

class TestWSHandler(tornado.websocket.WebSocketHandler):
    def open(self):
        print("Opened")

    def on_message(self, message):
        self.write_message("lol")

    def on_close(self):
        print("Closed")

application = tornado.web.Application([
    (r"/", TestWSHandler),
]);

if __name__ == "__main__":
    application.listen(1337)
    tornado.ioloop.IOLoop.instance().start()
