import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const String url = "ws://127.0.0.1:5000";
  WebSocketChannel? _channel;
  bool _isConnected = false;

  void connect() {
    _channel = IOWebSocketChannel.connect(Uri.parse(url));
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _channel!.sink.close();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Live Video"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: connect,
                      style: style,
                      child: const Text("Connect"),
                    ),
                    ElevatedButton(
                      onPressed: disconnect,
                      style: style,
                      child: const Text("Disconnect"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50.0,
                ),
                _isConnected
                    ? StreamBuilder(
                        stream: _channel!.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const Center(
                              child: Text("Connection Closed !"),
                            );
                          }
                          //? Working for single frames
                          return Image.memory(
                            Uint8List.fromList(
                              base64Decode(
                                (snapshot.data.toString()),
                              ),
                            ),
                            gaplessPlayback: true,
                          );
                        },
                      )
                    : const Text("Initiate Connection")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
