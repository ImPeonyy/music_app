import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../home/viewmodel.dart';
import '../now_playing/audio_player_manager.dart';
import '../now_playing/playing.dart';

class DiscoveryTab extends StatelessWidget {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HomeTab(),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  late MusicAppViewModel _viewModel = MusicAppViewModel();
  final FocusNode _focusNode = FocusNode();  // Tạo FocusNode
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    _searchController.addListener(_filterSongs);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 335,
              child: TextField(
                focusNode: _focusNode,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.search),
          ),

        ],
      ),
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    AudioPlayerManager().dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget getBody() {
    return getListView();
  }

  Widget getProgessBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: filteredSongs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(
        parent: this,
        song: filteredSongs[index]);
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs = songList;
        filteredSongs = songList;  // Initial filter is the full list
      });
    });
  }

  void _filterSongs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = songs
          .where((song) =>
      song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query))
          .toList();
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          height: 400,
          color: Colors.grey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal Bottom Sheet'),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Bottom Sheet'))
              ],
            ),
          ),
        ),
      );
    });
  }

  void navigate(Song song) {
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) {
          return NowPlaying(
            songs: songs,
            playingSong: song,
          );
        })
    );
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
          left: 24,
          right: 8
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
