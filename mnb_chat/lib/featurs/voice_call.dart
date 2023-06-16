// import 'dart:convert';
// 
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// 
// class VoiceCall extends StatefulWidget {
//   const VoiceCall({super.key});
// 
//   @override
//   State<VoiceCall> createState() => _VoiceCallState();
// }
// 
// class _VoiceCallState extends State<VoiceCall> {
//   @override
//   void initState() {
//     //  setupVoiceSDKEngine();
//     super.initState();
//   }
// 
//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();
//   String appId = '8aeb2f2a02fa4068bfe089bc7670e173';
//   String channelName = "mnb";
//   String token =
//       "007eJxTYOgTNT37ZIu3h1+ovwrTJeHvUz4yM5hfqVub9vfFVkletWwFBovE1CSjNKNEA6O0RBMDM4uktFQDC8ukZHMzc4NUQ3PjZsP2lIZARoZ1DFwMjFAI4jMz5OYlMTAAAK2MHKY=";
//   int uid = 0; // uid of the local user
// 
//   int? _remoteUid; // uid of the remote user
//   bool _isJoined = false; // Indicates if the local user has joined the channel
//   late RtcEngine agoraEngine;
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       home: Scaffold(
//         appBar: AppBar(
//             leading: TextButton(
//           onPressed: () {
//             getToken();
//           },
//           child: const Text(
//             'data',
//             style: TextStyle(fontSize: 50, color: Colors.black),
//           ),
//         )),
//         body: Center(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextButton(
//                   onPressed: () {
//                     join();
//                   },
//                   child: const Text('join channel')),
//               const SizedBox(width: 20),
//               TextButton(
//                   onPressed: () {
//                     join();
//                   },
//                   child: const Text('leave channel'))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// 
//   showMessage(String message) {
//     scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
//       content: Text(message),
//     ));
//   }
// 
//   Future<void> setupVoiceSDKEngine() async {
//     // retrieve or request microphone permission
//     await [Permission.microphone].request();
// 
//     //create an instance of the Agora engine
//     agoraEngine = createAgoraRtcEngine();
//     await agoraEngine.initialize(RtcEngineContext(appId: appId));
// 
//     // Register the event handler
//     agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           showMessage(
//               "Local user uid:${connection.localUid} joined the channel");
//           setState(() {
//             _isJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           showMessage("Remote user uid:$remoteUid joined the channel");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           showMessage("Remote user uid:$remoteUid left the channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );
//   }
// 
//   void join() async {
//     // Set channel options including the client role and channel profile
//     ChannelMediaOptions options = const ChannelMediaOptions(
//       clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     );
// 
//     await agoraEngine.joinChannel(
//       token: token,
//       channelId: channelName,
//       options: options,
//       uid: uid,
//     );
//   }
// 
//   void leave() {
//     setState(() {
//       _isJoined = false;
//       _remoteUid = null;
//     });
//     agoraEngine.leaveChannel();
//   }
// 
//   @override
//   void dispose() async {
//     await agoraEngine.leaveChannel();
//     super.dispose();
//   }
// 
//   Future<void> getToken() async {
//     print('object');
//     final response = await http.get(
//       Uri.parse('http://127.0.0.1/rtc/mnb/publisher/uid/0'
//           // To add expiry time uncomment the below given line with the time in seconds
//           // + '?expiry=45'
//           ),
//     );
//     print(response.body);
//     if (response.statusCode == 200) {
//       setState(() {
//         token = response.body;
//         token = jsonDecode(token)['rtcToken'];
//       });
//     } else {
//       print('Failed to fetch the token');
//     }
//   }
// }
