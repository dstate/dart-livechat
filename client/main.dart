import 'dart:html';
import 'dart:async';

void main() {
    WebSocket ws;

    ws = new WebSocket('ws://localhost:1337');

    ws.onOpen.listen((e) {
        ws.send('slt ler fise de vo mer');
    });

    ws.onMessage.listen((MessageEvent e) {
        InputElement elem;
        elem = querySelector('#output');
        elem.value = e.data;
    });
}
