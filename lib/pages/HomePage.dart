import 'dart:ffi';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{

  final audioPlayer = AudioPlayer();

  bool isPlaying = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late AnimationController animationController;
  late Animation<double> animation;  // Fix the type here
  

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }


  @override
  void initState() {
    // TODO: implement initState

    // setAudio();

    animationController = AnimationController(vsync: this, duration:const Duration(seconds: 4));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationController.repeat();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            child: CircleAvatar(
              radius: 140,
              backgroundImage: AssetImage("images/disque_2.png"),
            ),
            turns: animationController
          ),
          
          SizedBox(
            height: 32,
          ),
          Text(
            "The Flutter Song",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Sarah Abs",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 4),

          Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds:value.toInt());
              await audioPlayer.seek(position);

              /// Optional : Play audio if was paused
              await audioPlayer.resume();
            },
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration - position))
              ],
            ),
          ),
          CircleAvatar(
            radius: 35,
            child: IconButton(
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  String url =  "https://www.auboutdufil.com/get.php?fla=https://archive.org/download/karol-piczak-les-champs-etoiles/KarolPiczak-LesChampsEtoiles.mp3";
                  await audioPlayer.play(UrlSource(url));
                }
              },
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 50,
            ),
          )
        ],
      )),
    );
  }
  
  Future setAudio() async{
    //Repeat song when completed
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    //// Load audio from URL
    // String url =  "https://www.auboutdufil.com/get.php?fla=https://archive.org/download/karol-piczak-les-champs-etoiles/KarolPiczak-LesChampsEtoiles.mp3";
    // audioPlayer.setSourceUrl(url);

    //// Load audio from File
    // final file = File("/assets/musique.mp3");
    // audioPlayer.setSourceAsset(file as String);

    /// Load audio from file
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      audioPlayer.setSourceDeviceFile(file.path);
    }
    
  }
}
