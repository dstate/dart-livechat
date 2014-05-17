import tornado.ioloop
import tornado.web

from ChatHandler import ChatHandler

application = tornado.web.Application([
    (r"/", ChatHandler),
]);

if __name__ == "__main__":
    application.listen(1337)
    tornado.ioloop.IOLoop.instance().start()
