import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArtistSectionHeader extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const ArtistSectionHeader({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      sliver: SliverToBoxAdapter(
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge,)),
          if(onPressed != null) ...[
            ElevatedButton(
              onPressed: onPressed,
              child: Text(AppLocalizations.of(context)!.artist_showAll),
            )
          ]
        ]),
      ),
    );
  }
}
