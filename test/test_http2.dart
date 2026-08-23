import "dart:io";
import "dart:convert";
import "package:http2/http2.dart";

void main() async {
  final uri = Uri.parse("https://cdn.readcomicsonline.ru/uploads/manga/absolute-batman-2024/chapters/22/01-80efc8ddae9bda2cac1b0e136f3e21de.webp");
  final socket = await SecureSocket.connect(
    uri.host,
    443,
    supportedProtocols: ["h2"],
  );
  
  final transport = ClientTransportConnection.viaSocket(socket);
  final headers = [
    Header.ascii(':method', 'GET'),
    Header.ascii(':path', uri.path),
    Header.ascii(':scheme', uri.scheme),
    Header.ascii(':authority', uri.host),
    Header.ascii('user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Safari/537.36'),
    Header.ascii('referer', 'https://readcomicsonline.ru/'),
    Header.ascii('accept', 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8'),
  ];
  
  final stream = transport.makeRequest(headers, endStream: true);
  final chunks = <int>[];
  var statusCode = 0;
  
  await for (final message in stream.incomingMessages) {
    if (message is HeadersStreamMessage) {
      for (final header in message.headers) {
        final name = utf8.decode(header.name);
        final value = utf8.decode(header.value);
        if (name == ':status') {
          statusCode = int.parse(value);
        }
      }
    } else if (message is DataStreamMessage) {
      chunks.addAll(message.bytes);
    }
  }
  
  await transport.finish();
  print("HTTP/2 Status Code: $statusCode");
  print("HTTP/2 Downloaded Bytes: ${chunks.length}");
}
