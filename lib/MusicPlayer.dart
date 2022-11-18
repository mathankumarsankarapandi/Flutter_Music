import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/CommonWidgets.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> with SingleTickerProviderStateMixin{

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
      await audioPlayer.play(songModelList[currentIndex].data);
      isAudioPlaying = true;
      setState(() {

      });
    });
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
        leading: Visibility(
          visible: !musicListShown!,
          child: IconButton(
              onPressed: () {
                musicListShown = true;
                commonWidgets.setBoolean("MusicListShown", true);
                setState(() {

                });
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        centerTitle: true,
        title: commonWidgets.setTextWithColor("Music Player 2022", 15,Colors.white),
      ),
      body: Visibility(
          visible: musicListShown!,
          replacement: musicPlayerView(),
          child: musicListView()),
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
            height: 70,
            color: Colors.blue,
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
                    musicListShown = false;
                    commonWidgets.setBoolean("MusicListShown", false);
                    isAudioPlaying = true;
                  });
                  audioPlayer.notificationService;
                  await audioPlayer.play(songModelList[currentIndex].data);
                },
                leading: const Icon(Icons.music_note_sharp),
                title: commonWidgets.setTextWithColor(item.data![index].displayNameWOExt, 15,Colors.blue),
                subtitle: commonWidgets.setTextWithColor("${item.data![index].artist}", 10, Colors.black),
                trailing: const Icon(Icons.more_horiz_sharp),
              );
            });
      },
    );
  }

  Widget musicPlayerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        imageView(),
        timerView(),
        buttonView()
      ],
    );
  }

  Widget imageView() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: commonWidgets.setTextWithColor(currentPlaySong,18,Colors.black)),
                GestureDetector(
                    onTap: () {
                      listView();
                    },
                    child: commonWidgets.iconContainer(Icons.list_sharp, Colors.black,25))
              ],
            )),
        const Image(image: AssetImage("assests/music.png")),
        // Container(
        //     height: MediaQuery.of(context).size.width * 0.8,
        //     width: MediaQuery.of(context).size.width * 0.8,
        //     decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assests/music.png"))),
        //     child: musicAnimation(),
        // )
        /*child: Image(image: const AssetImage("assests/image.jpg"),fit: BoxFit.fitWidth)*/

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
          commonWidgets.setTextWithColor(commonWidgets.setTime(position), 12, Colors.black),
          Expanded(
            child: Slider(
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                  await audioPlayer.resume();
                }),
          ),
          commonWidgets.setTextWithColor(commonWidgets.setTime(duration-position), 12, Colors.black),
        ],
      ),
    );
  }

  Widget buttonView() {
    return Container(
      color: Colors.transparent,
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
                await audioPlayer.play(songModelList[currentIndex].data);
                isAudioPlaying = true;
                setState(() {

                });
              },
              child: commonWidgets.iconContainer(Icons.skip_previous_sharp,Colors.black,35),
            ),
            GestureDetector(
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
              },
              child: commonWidgets.iconContainer(isAudioPlaying ? Icons.pause_sharp : Icons.play_arrow_sharp,Colors.black,35),
            ),
            GestureDetector(
              onTap: () async {
                if(currentIndex == songModelList.length -1){
                  currentIndex = 0;
                } else {
                  currentIndex += 1;
                }
                currentPlaySong = songModelList[currentIndex].displayNameWOExt;
                await audioPlayer.play(songModelList[currentIndex].data);
                isAudioPlaying = true;
                setState(() {

                });
              },
              child:commonWidgets.iconContainer(Icons.skip_next_sharp,Colors.black,35),
            ),
          ]
      ),
    );
  }

}