import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/CommonWidgets.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:text_scroll/text_scroll.dart';

class MusicView extends StatefulWidget {
  const MusicView({Key? key}) : super(key: key);

  @override
  State<MusicView> createState() => MusicViewState();
}

class MusicViewState extends State<MusicView> with SingleTickerProviderStateMixin{

  final OnAudioQuery audioQuery = OnAudioQuery();
  final AudioPlayer audioPlayer = AudioPlayer();
  CommonWidgets commonWidgets = CommonWidgets();
  bool isAudioPlaying = false;
  bool? musicListShown = true;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  List<SongModel> songModelList = [];
  int currentIndex = 0;
  String currentPlaySong = "";
  String currentPlaySongArtist = "";

  late Animation<double> animation;
  late AnimationController animationController;
  List<Color> color = [Colors.red,Colors.blue,Colors.yellow,Colors.grey,Colors.purple];
  List<double> durationAnimation = [10 , 50,30 ,20,45];

  void setMusicListShown() async {
    musicListShown = await commonWidgets.getBoolean("MusicListShown");
    setState(() {

    });
  }

  @override
  void initState() {

    setMusicListShown();

    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    audioPlayer.onPlayerCompletion.listen((event) async {
      if(currentIndex == songModelList.length -1){
        currentIndex = 0;
      } else {
        currentIndex += 1;
      }
      currentPlaySong = songModelList[currentIndex].displayNameWOExt;
      currentPlaySongArtist = songModelList[currentIndex].artist!;
      await audioPlayer.play(songModelList[currentIndex].data);
      isAudioPlaying = true;
      setState(() {

      });
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    animationController.repeat();
    // animationController = AnimationController(vsync: this,duration: const Duration(milliseconds: 500));
    // final curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.ease);
    //
    // animation = (Tween<double>(begin: 0,end: 100).animate(curvedAnimation)..addListener(() {
    //   setState(() {
    //
    //   });
    // }));

    // animationController.repeat(reverse: true);
    super.initState();
    requestPermission();
  }



  requestPermission() async {
    // bool permissionStatus = await audioQuery.permissionsStatus();
    // if (!permissionStatus) {
    //   await audioQuery.permissionsRequest();
    // }
    // setState(() {});
    await Permission.storage.request();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        elevation: 0,
        leading: Visibility(
          visible: !musicListShown!,
          child: IconButton(
              onPressed: () {
                musicListShown = true;
                commonWidgets.setBoolean("MusicListShown", true);
                setState(() {

                });
              },
              icon: const Icon(Icons.arrow_drop_down_sharp)),
        ),
        centerTitle: true,
        title: commonWidgets.setTextWithColor("Music Player 2022", 15,Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade800,
              Colors.brown.shade700,
              Colors.brown.shade600,
              Colors.brown.shade500,
              Colors.brown.shade400,
              Colors.brown.shade300,
            ],
          ),
        ),
        child: Visibility(
            visible: musicListShown!,
            replacement: musicPlayerView(),
            child: musicListView()),
      ),
      bottomNavigationBar: Visibility(
        visible: currentPlaySong != "" && musicListShown!,
        child: GestureDetector(
          onTap: () {
            musicListShown = false;
            commonWidgets.setBoolean("MusicListShown", false);
            setState(() {

            });
          },
          child: Container(
            padding: EdgeInsets.only(left: 10),
            height: 70,
            color: Colors.brown.shade500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commonWidgets.setTextWithColor(currentPlaySong, 15, Colors.white),
                Row(
                  children: [
                    InkWell(
                        onTap: () async {
                          if(currentIndex == 0){
                            currentIndex = songModelList.length -1;
                          } else {
                            currentIndex -= 1;
                          }
                          currentPlaySong = songModelList[currentIndex].displayNameWOExt;
                          currentPlaySongArtist = songModelList[currentIndex].artist!;
                          await audioPlayer.play(songModelList[currentIndex].data);
                          isAudioPlaying = true;
                          setState(() {

                          });
                        },
                        child: commonWidgets.iconContainer(Icons.skip_previous_sharp, Colors.white, 30)),
                    InkWell(
                        onTap: () async{
                          if(isAudioPlaying){
                            await audioPlayer.pause();
                            isAudioPlaying = false;
                          } else {
                            await audioPlayer.play(songModelList[currentIndex].data);
                            isAudioPlaying = true;
                          }
                          setState(() {

                          });
                        },child: commonWidgets.iconContainer(isAudioPlaying ? Icons.pause_sharp : Icons.play_arrow, Colors.white, 30)),
                    InkWell(
                        onTap: () async {
                          if(currentIndex == songModelList.length -1){
                            currentIndex = 0;
                          } else {
                            currentIndex += 1;
                          }
                          currentPlaySong = songModelList[currentIndex].displayNameWOExt;
                          currentPlaySongArtist = songModelList[currentIndex].artist!;
                          await audioPlayer.play(songModelList[currentIndex].data);
                          isAudioPlaying = true;
                          setState(() {

                          });
                        },child: commonWidgets.iconContainer(Icons.skip_next_sharp, Colors.white, 30)),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget musicListView() {
    return FutureBuilder<List<SongModel>>(
      future: audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      ),
      builder: (context, item) {
        if (item.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (item.data!.isEmpty) {
          return const Center(child: Text("Nothing found!"));
        }
        songModelList = item.data!;
        return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () async{
                  setState(() {
                    currentIndex = index;
                    currentPlaySong = item.data![index].displayNameWOExt;
                    currentPlaySongArtist = item.data![index].artist!;
                    musicListShown = false;
                    commonWidgets.setBoolean("MusicListShown", false);
                    isAudioPlaying = true;
                  });
                  audioPlayer.notificationService;
                  await audioPlayer.play(songModelList[currentIndex].data);
                },
                leading: const Icon(Icons.music_note_sharp,color: Colors.white),
                title: commonWidgets.setTextWithColor(item.data![index].displayNameWOExt, 16,Colors.white),
                subtitle: commonWidgets.setTextWithColor("${item.data![index].artist}", 10, Colors.white),
                trailing: const Icon(Icons.more_horiz_sharp, color: Colors.white),
              );
            });
      },
    );
  }

  Widget musicPlayerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        imageView(),
        timerView(),
        buttonView()
      ],
    );
  }

  Widget imageView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        AnimatedBuilder(
          animation: animationController,
          child:  Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.65,
            color: Colors.transparent,
            child: const Image(
                image: AssetImage("assests/music_background.png"),
                color: Colors.white,
                fit: BoxFit.contain),
          ),
          builder: (BuildContext context, Widget? _widget) {
            return Transform.rotate(
              angle: animationController.value * 6.3,
              child: _widget,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonWidgets.setTextWithColorFOntWeight(currentPlaySong, 18, Colors.white),
               TextScroll(
                currentPlaySongArtist,
                mode: TextScrollMode.endless,
                velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
                delayBefore: Duration(milliseconds: 50),
                numberOfReps: 5,
                pauseBetween: Duration(milliseconds: 50),
                style: TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.right,
                selectable: true,
              )
            ],
          ),
        )
      ],
    );
  }

  Widget musicAnimation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(10, (index) => animateContainer(color[index % 5],durationAnimation[index % 5])),
    );
  }

  Widget animateContainer(Color color, double height) {
    return Container(
      width: 10,
      height: animation.value+height,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10)
      ),
    );
  }

  void listView () {
    showModalBottomSheet(
        context: context, builder: (BuildContext buildContext) {
      return ListView.builder(
        itemCount: songModelList.length,
        itemBuilder: (BuildContext listContext, int index) {
          return ListTile(
            onTap: () async{
              setState(() {
                currentIndex = index;
                currentPlaySong = songModelList[index].displayNameWOExt;
                currentPlaySongArtist = songModelList[index].artist!;
                musicListShown = false;
                commonWidgets.setBoolean("MusicListShown", false);
                isAudioPlaying = true;
              });
              await audioPlayer.play(songModelList[currentIndex].data);
            },
            leading: const Icon(Icons.music_note_sharp),
            title: commonWidgets.setTextWithColor(songModelList[index].displayNameWOExt, 15,Colors.blue),
            subtitle: commonWidgets.setTextWithColor("${songModelList[index].artist}", 10, Colors.black),
            trailing: const Icon(Icons.more_horiz_sharp),
          );
        },
      );
    });
  }

  Widget timerView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0,0,8,10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          commonWidgets.setTextWithColor(commonWidgets.setTime(position), 12, Colors.white),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.grey,
                trackShape: const RectangularSliderTrackShape(),
                trackHeight: 2.0,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0,),
                overlayColor: Colors.transparent,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 6.0),
              ),
              child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                  }),
            ),
          ),
          commonWidgets.setTextWithColor(commonWidgets.setTime(duration-position), 12, Colors.white),
        ],
      ),
    );
  }

  Widget buttonView() {
    return Container(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            GestureDetector(
              onTap: () async {
                if(currentIndex == 0){
                  currentIndex = songModelList.length -1;
                } else {
                  currentIndex -= 1;
                }
                currentPlaySong = songModelList[currentIndex].displayNameWOExt;
                currentPlaySongArtist = songModelList[currentIndex].artist!;
                await audioPlayer.play(songModelList[currentIndex].data);
                isAudioPlaying = true;
                setState(() {

                });
              },
              child: commonWidgets.iconContainer(Icons.skip_previous_sharp,Colors.white,35),
            ),
            GestureDetector(
              onTap: () async{
                if(isAudioPlaying){
                  await audioPlayer.pause();
                  animationController.stop();
                  isAudioPlaying = false;
                } else {
                  animationController.repeat();
                  await audioPlayer.play(songModelList[currentIndex].data);
                  isAudioPlaying = true;
                }
                setState(() {

                });
              },
              child: commonWidgets.iconContainer(isAudioPlaying ? Icons.pause_sharp : Icons.play_arrow_sharp,Colors.white,35),
            ),
            GestureDetector(
              onTap: () async {
                if(currentIndex == songModelList.length -1){
                  currentIndex = 0;
                } else {
                  currentIndex += 1;
                }
                currentPlaySong = songModelList[currentIndex].displayNameWOExt;
                currentPlaySongArtist = songModelList[currentIndex].artist!;
                await audioPlayer.play(songModelList[currentIndex].data);
                isAudioPlaying = true;
                setState(() {

                });
              },
              child:commonWidgets.iconContainer(Icons.skip_next_sharp,Colors.white,35),
            ),
          ]
      ),
    );
  }

}