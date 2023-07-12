import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:badges/badges.dart'as badges;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart'as path;
import 'package:path_provider/path_provider.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool RecPausePlay=true;
  bool PausePlay=true;
  int badge=0;
  bool showBadge=false;
  late FlutterSoundRecorder _recordingSession;
   String PathToAudio="";
   final recordingPlayer=AssetsAudioPlayer();
   bool _playAudio=false;
    String  _timerText="00:00:00";
    int _recordNumber=0;  
    List<String> Alist=[];
    bool isRecording=false;
    bool isstream=true;
    @override
   void initState() {
        initializer();
    super.initState();
  }
   @override
  void dispose() {
     _recordingSession.closeRecorder();
    print("object");
    super.dispose();
  }
  adder(){
    Alist.add(PathToAudio);
  }
  void initializer() async {
    _recordingSession = FlutterSoundRecorder();
    final mStatus=await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage;
    if (mStatus!= PermissionStatus.granted){
      throw "permission revoked";
    }
    await _recordingSession.openRecorder();
      await _recordingSession.setSubscriptionDuration(const Duration(
    milliseconds: 100));
  }
  Future<String> _getAudioDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDirPath = '${appDir.path}/audio';
    final audioDir = Directory(audioDirPath);
    if (!await audioDir.exists()) {
      await audioDir.create();
    }
    print("asssdd $audioDirPath $audioDir");
    return audioDirPath;
    
  }
  Future<String> _getNextFilePath() async {
    final audioDirPath = await _getAudioDirectoryPath();
    final filePath = '$audioDirPath/recording${++_recordNumber}.aac';
    setState(() {
      PathToAudio=filePath;
    });
    print(filePath);
    return filePath;
  }
  Future<void> startRecording() async {
   try {
      
     // await _recordingSession.openRecorder();
      final filePath = await _getNextFilePath();
      await _recordingSession.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4,
        );
      setState(() {
       // _isRecording = true;
       // _recordFilePath = filePath;
      });
    } catch (e) {
      debugPrint('Error while recording: $e');
    }
  }
   Future<String?> stopRecording() async {
   // final filePath = await
     _recordingSession.stopRecorder();
   // final file = File(filePath!) ;
   // print("RFile Path: $file $filePath");
  }
  
  Future<void> pauseRecording()async{
    _recordingSession.pauseRecorder();
  }
  Future<void> resumeRecording()async{
    _recordingSession.resumeRecorder();
  }
  
   Future<void> playFunc(int i) async {
    recordingPlayer.open(
      Audio.file(Alist[i]),
      autoStart: true,
      showNotification: true,
    );
  }
  Future<void> pausePlayFunc() async {
    recordingPlayer.playOrPause();
  }
    Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }


  recButton(){
     return Container(
                  height: 100,width: 100,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                  color:Colors.pink[50],),
                  child: RecPausePlay? IconButton(
                    onPressed: (){startRecording();
                    setState(() {
                      RecPausePlay=false;
                      isRecording=true;
                      isstream=true;
                     // showBadge=true;
                    },
                    );
                  },
                     icon: const Icon(Icons.mic,
                     size: 70,
                     color: Colors.pink,
                     )
                     ):PausePlay? IconButton(onPressed: (){
                      pauseRecording();
                    setState(() {
                     PausePlay =false;
                    });
                  },
                     icon: const Icon(Icons.pause_circle, size: 70,
                           color: Colors.pink,
                          )
                     ):
                     IconButton(onPressed: (){
                      resumeRecording();
                    setState(() {
                     PausePlay =true;

                    });
                  },
                     icon: const Icon(Icons.play_circle_fill, size: 70,
                           color: Colors.pink,
                          )
                     )
                );
  }
  gauges(){
    return Padding(
                  padding: const EdgeInsets.all(50),
                  child: Container(
                  decoration: BoxDecoration(
                   // boxShadow:[PhysicalModel(color: Colors.black)],
                  ),
                    child: SfRadialGauge(
                      axes: [
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          startAngle: 90,endAngle: 90,
                          showLabels: false,
                          showTicks: false,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.1,
                            gradient: SweepGradient(colors: [Colors.pink,Colors.deepPurple,Colors.blue,Colors.indigo]),
                          thicknessUnit: GaugeSizeUnit.factor
                          ),
                          pointers: [
                            RangePointer(value:100,
                            cornerStyle: CornerStyle.bothCurve,
                            width: 0.05,
                            pointerOffset: 0.1,
                            color:Colors.pink,
                            sizeUnit: GaugeSizeUnit.factor,
                            gradient: SweepGradient(colors: [Colors.pink,Colors.deepPurple,Colors.blue,Colors.indigo]),
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation( 
                              positionFactor: 0.1,
                              angle: 90,
                              widget: isstream?Text(_timerText,style: TextStyle(fontSize: 30),):Text("00:00:00",style: TextStyle(fontSize: 30)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
  }
  
  @override
  Widget build(BuildContext context) { int values=0;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
        child: Container(
          height: 60,
          child: FloatingActionButton.extended(
           // focusElevation: null,
            backgroundColor: Colors.pink[50],
            onPressed: (){}, 
          label: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  ),
                  child:
                  badges.Badge(
                    showBadge: showBadge,
                    //BadgeAnimationType: badges.BadgeAnimationType.slide,
                    badgeContent: Text("${Alist.length }"),
                    child:_playAudio? IconButton(
                    onPressed: (){
                    },
                   icon: const Icon(Icons.music_note_outlined,
                   color: Colors.pink,
                   )):IconButton(
                    onPressed: (){
                    },
                   icon: const Icon(Icons.music_off_outlined,
                   color: Colors.pink,
                   ))
                  )
                ),
              ),
               recButton(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white
                  ),
                  child:isRecording? IconButton(
                    onPressed: (){
                   showBadge=true;
                      setState(() {
                        stopRecording();
                        adder();
                      RecPausePlay=true;
                      isRecording=false;
                      isstream=false;
                     // badge=0;
                    // 
                      PausePlay=true;
                    });
                    },
                   icon: const Icon(Icons.done_sharp,
                   color: Colors.red,
                   )):IconButton(onPressed: (){}, icon: Icon(Icons.multitrack_audio_sharp,color:_playAudio? Colors.red: Colors.grey,))
                   )
                ),
            ],
          ),
         ),
        ),
      ) ,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 135),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(24)),
                    child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Stack(
                             children: [Text("AUDIO",style: TextStyle(fontSize: 30,
                              fontWeight: FontWeight.w600 ,fontStyle:
                               FontStyle.italic,
                               foreground: Paint()
                                ..style=PaintingStyle.stroke
                                ..strokeWidth=4
                                ..color=Colors.pink
                               // ..shader=Shader.
                                ),),
                                Text("AUDIO",style: TextStyle(fontSize: 30,
                              fontWeight: FontWeight.w600 ,fontStyle:
                               FontStyle.italic,
                               color: Colors.pink.shade300
                               )),Text("\n\n Recorder",
                               style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color:Colors.pink[500],),),         
                                ]
                            ),
                          ),
                          Spacer(),
                          IconButton(onPressed: (){}, icon: Icon(Icons.menu_sharp,color: Colors.pink,))
                        ],
                      ),
                  ),
                ),
                StreamBuilder<RecordingDisposition>(builder: (context,snapshot){
                final duration = snapshot.hasData?snapshot.data!.duration: Duration.zero;
                String twoDigits(int n)=>n.toString().padLeft(2,"0");
                final twoDigitHours=twoDigits(duration.inHours.remainder(12));
                final twoDigitMinutes=twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds=twoDigits(duration.inSeconds.remainder(60));
                  _timerText="$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
                return gauges();
              },
              stream:_recordingSession.onProgress,
              ),
               //gauges(),
                Container(
                  height: 150,
                 child: ListView.builder(
                    itemCount: Alist.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                       splashColor: Colors.black,
                        onTap: (){},
                        child:ListTile(//tileColor: issele ?Colors.pink[100]:Colors.white,
                         onTap: () {
                          playFunc(index);
                          setState(() {
                            _playAudio=true;
                          });
                        },
                        leading: Text("${index+1}"),
                        title: Text(path.basename(Alist[index])),
                        trailing: !_playAudio? IconButton(onPressed: (){
                          setState(() {
                            _playAudio=true;
                          });
                        }, icon: Icon(Icons.play_arrow_rounded)):
                         IconButton(onPressed: (){
                          setState(() {
                            _playAudio=false;
                          });
                        }, icon: Icon(Icons.pause)),
                        )
                      );
                    },
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
    
  }}