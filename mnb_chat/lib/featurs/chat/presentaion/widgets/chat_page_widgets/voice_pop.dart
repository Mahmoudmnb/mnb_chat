// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import '../../../../auth/models/user_model.dart';
import '../../../models/message.dart';

class VoicPop extends StatefulWidget {
  final bool isme;
  final MessageModel message;
  final String chatId;
  final UserModel friend;
  const VoicPop({
    Key? key,
    required this.isme,
    required this.message,
    required this.chatId,
    required this.friend,
  }) : super(key: key);

  @override
  State<VoicPop> createState() => _VoicPopState();
}

class _VoicPopState extends State<VoicPop> {
  PlayerController controller = PlayerController();
  String path = '';
  List<double> waveformData = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onLongPress: () async {
        // waveformData = await controller.extractWaveformData(
        //   path: widget.message.senderPath!,
        //   noOfSamples: 100,
        // );
        // setState(() {});
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          constraints: BoxConstraints(
              maxWidth: deviceSize.width * 0.7,
              minWidth: deviceSize.width * 0.1),
          decoration: BoxDecoration(
              color: widget.isme
                  ? Theme.of(context).colorScheme.onBackground
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(widget.isme ? 15 : 0),
                  bottomRight: Radius.circular(widget.isme ? 0 : 15),
                  topLeft: const Radius.circular(15))),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        
                        // await controller.preparePlayer(
                        //     path: widget.message.senderPath!);
                        controller.startPlayer(finishMode: FinishMode.stop);
                      },
                      icon: const Icon(Icons.play_arrow)),
                  AudioFileWaveforms(
                    size: const Size(150, 100.0),
                    playerController: controller,
                    enableSeekGesture: true,
                    // waveformType: WaveformType.long,
                    // waveformData: waveformData,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: Colors.white54,
                      liveWaveColor: Colors.blueAccent,
                      // spacing: 6,
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
