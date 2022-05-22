// ignore_for_file: library_private_types_in_public_api

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:vibration/vibration.dart' show Vibration;

class TrimmerScreen extends StatefulWidget {
  static String id = 'TrimmerScreen';
  const TrimmerScreen({Key? key}) : super(key: key);

  @override
  _TrimmerScreenState createState() => _TrimmerScreenState();
}

class _TrimmerScreenState extends State<TrimmerScreen> {
  bool vibrating = false;
  final assetsAudioPlayer = AssetsAudioPlayer();

  playAudio() async {
    assetsAudioPlayer.open(
      Audio("assets/audio/trimmer.mp3"),
      seek: const Duration(milliseconds: 300),
      loopMode: LoopMode.single,
      playInBackground: PlayInBackground.enabled,
    );
    debugPrint('play');
  }

  pauseAudio() async {
    assetsAudioPlayer.stop();
    debugPrint('stop');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    assetsAudioPlayer.stop();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (vibrating) {
          await assetsAudioPlayer.stop();
          await Vibration.cancel();
        }
        await SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/img/trimmer.jpg',
                  fit: BoxFit.fitHeight,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    if (vibrating) {
                      Vibration.cancel();
                      Fluttertoast.showToast(
                        msg: 'Vibration Stopped',
                      );
                      setState(() {
                        vibrating = false;
                      });
                      pauseAudio();
                    } else {
                      if (await Vibration.hasVibrator()) {
                        if (await Vibration.hasCustomVibrationsSupport()) {
                          setState(() {
                            vibrating = true;
                          });
                          if (await Vibration.hasAmplitudeControl()) {
                            Vibration.vibrate(
                              duration: 30000,
                              amplitude: 255,
                            );
                            playAudio();
                            debugPrint('with amplitude');
                          } else {
                            Vibration.vibrate(
                              duration: 30000,
                            );
                            playAudio();
                            debugPrint('no amplitude');
                          }
                        } else {
                          playAudio();
                          Vibration.vibrate(
                            duration: 30000,
                          );

                          debugPrint('no custom vibration');
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Vibration Not Supported',
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.only(bottom: 30, right: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        vibrating
                            ? const BoxShadow(
                                color: Colors.blue,
                                blurRadius: 10,
                                spreadRadius: 2,
                                blurStyle: BlurStyle.outer,
                              )
                            : const BoxShadow(
                                color: Colors.black,
                                blurRadius: 3,
                                spreadRadius: 3,
                                blurStyle: BlurStyle.outer,
                              ),
                      ],
                    ),
                    child: vibrating
                        ? const Icon(
                            Icons.power_settings_new_outlined,
                            color: Colors.blue,
                          )
                        : const Icon(
                            Icons.power_settings_new_outlined,
                            color: Colors.black,
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
