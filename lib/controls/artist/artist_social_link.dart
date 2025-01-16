import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '/models/music_api/artist.dart';

class ArtistSocialLink extends StatelessWidget {
  final ArtistLink link;

  const ArtistSocialLink(this.link, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    String? title;

    switch(link.type) {
      case 'official':
        icon = const Icon(Icons.language);
        title = link.title;
      case 'social':
        switch(link.socialNetwork!) {
          case 'youtube':
            icon = const FaIcon(FontAwesomeIcons.youtube);
            title = 'youtube';
          case 'twitter':
            icon = const FaIcon(FontAwesomeIcons.twitter);
            title = 'twitter';
          case 'vk':
            icon = const FaIcon(FontAwesomeIcons.vk);
            title = 'vk';
          case 'bandlink':
            icon = const Icon(Icons.language);
            title = 'bandlink';
          case 'telegram':
            icon = const FaIcon(FontAwesomeIcons.telegram);
            title = 'telegram';
        }
    }

    return OutlinedButton(
        onPressed: () async {
          await launchUrl(Uri.parse(link.href));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(icon != null) icon,
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(title ?? ''),
            )
          ],
        )
    );
  }
}