import 'package:flutter/material.dart';
import 'package:ya_player/controls/account_area.dart';

import '../helpers/nav_keys.dart';

class PageBaseLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const PageBaseLayout({super.key, required this.body, required this.title});

  void _goToRoute(String route) {
    NavKeys.mainNav.currentState!.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (ModalRoute.of(context)?.canPop ?? false) ? const BackButton() : null,
        title: Text(title),
      ),
      body: body,
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.radio_outlined),
                    title: const Text('Stations'),
                    onTap: () => _goToRoute('/stations'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Tracks'),
                    onTap: () => _goToRoute('/tracks'),
                  ),ListTile(
                    leading: const Icon(Icons.album),
                    title: const Text('Albums'),
                    onTap: () => _goToRoute('/albums'),
                  ),ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Artists'),
                    onTap: () => _goToRoute('/artists'),
                  ),ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: const Text('Playlists'),
                    onTap: () => _goToRoute('/playlists'),
                  )
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.man),
              title: AccountArea()
            )
          ],
        ),
      ),
    );
  }
}