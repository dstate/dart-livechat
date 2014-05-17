import 'dart:html';
import 'dart:async';

WebSocket ws;

void sendNick(Event e) {
    InputElement inputNick;

    inputNick = querySelector("#inputSetNick");
    ws.send(inputNick.value);
}

void main() {
    ButtonElement btnNick;

    ws = new WebSocket('ws://localhost:1337');
    btnNick = querySelector("#btnSetNick");

    btnNick.onClick.listen(sendNick);
}
