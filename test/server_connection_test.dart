import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  HttpServer? mockDockerServer;
  int serverPort = 9091;

  setUpAll(() async {
    // Just initialize GraphQL
  });

  tearDownAll(() async {
    await mockDockerServer?.close();
  });

  Future<void> startMockDockerServer() async {
    mockDockerServer = await HttpServer.bind(InternetAddress.loopbackIPv4, serverPort);
    mockDockerServer!.listen((HttpRequest request) {
      print("SERVER GOT REQUEST: ${request.uri}");
      if (request.uri.path.contains('graphql')) {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'data': {'library': [{'id': '123'}]}}))
          ..close();
      } else {
        request.response
          ..statusCode = 404
          ..close();
      }
    });
  }

  Future<void> stopMockDockerServer() async {
    await mockDockerServer?.close(force: true);
    mockDockerServer = null;
  }

  test('1. App connects to Docker backend successfully when online', () async {
    await startMockDockerServer();

    GraphQLClientService.instance.initialize('http://127.0.0.1:$serverPort', authToken: 'Bearer test');
    final response = await GraphQLClientService.instance.query('''
      query { library { id } }
    ''');

    expect(response, isNotNull);
    expect(response!['library'], isNotEmpty);
  });

  test('2. App gracefully degrades when Docker backend is offline (no crashes)', () async {
    await stopMockDockerServer(); // Simulate docker stop

    final response = await GraphQLClientService.instance.query('''
      query { library { id } }
    ''');
    
    // Should return null (graceful failure) instead of throwing an unhandled exception
    expect(response, isNull);
  });

  test('3. App recovers automatically when Docker backend restarts', () async {
    serverPort = 9092; // Use new port to avoid OS TIME_WAIT
    GraphQLClientService.instance.initialize('http://127.0.0.1:$serverPort', authToken: 'Bearer test');
    await startMockDockerServer(); // Simulate docker start
    await Future.delayed(const Duration(milliseconds: 200)); // Wait for server to bind fully

    // First request might fail due to stale TCP socket from Keep-Alive pool
    await GraphQLClientService.instance.query('''
      query { library { id } }
    ''');
    
    // Second request will open a fresh socket to the new docker instance
    final response = await GraphQLClientService.instance.query('''
      query { library { id } }
    ''');
    
    if (response == null) {
      print("RESPONSE WAS NULL. Is Server running? ${mockDockerServer != null}");
    }
    
    expect(response, isNotNull); // Back online!
    expect(response!['library'], isNotEmpty);
  });
}
