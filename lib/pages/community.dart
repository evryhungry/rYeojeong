import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re/controller/app_state.dart';
import '../model/communities.dart';
import 'cardview.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            semanticLabel: 'back',
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('커뮤니티'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              // AddCommunityPage로 이동
              Navigator.pushNamed(context, '/community/add');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Communities>>(
        stream: appState.fetchCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No communities in stream');
            return const Center(child: Text('No communities found'));
          }
          debugPrint('Data loaded: ${snapshot.data}');
          return CardView(communityList: snapshot.data!);
        },
      ),
    );
  }
}
