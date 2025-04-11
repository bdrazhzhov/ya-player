import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';

class AppSearchBar extends StatefulWidget {
  final void Function(String)? onChanged;

  const AppSearchBar({super.key, this.onChanged});

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final searchTextController = TextEditingController();
  bool isLeadingHidden = true;
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeColor = theme.colorScheme.secondary;
    final inactiveColor = theme.colorScheme.secondary.withAlpha(150);
    var hintTextStyle = theme.textTheme.titleMedium!.copyWith(
      color: inactiveColor
    );

    return SearchBar(
      controller: searchTextController,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(Icons.search, color: isActive ? activeColor : inactiveColor),
      ),
      trailing: !isLeadingHidden ? [
        IconButton(
          icon: Icon(Icons.clear, color: isActive ? activeColor : inactiveColor),
          onPressed: (){
            searchTextController.clear();
            isLeadingHidden = true;
            setState(() {});
            if(widget.onChanged != null) widget.onChanged!('');
          },
        )
      ] : null,
      onChanged: (text){
        isLeadingHidden = text.isEmpty;
        setState(() {});
        if(widget.onChanged != null) widget.onChanged!(text);
      },
      onTap: (){
        isActive = true;
        setState(() {});
      },
      onTapOutside: (_){
        isActive = false;
        setState(() {});
      },
      elevation: WidgetStateProperty.all<double>(0.0),
      hintText: l10n.searchbar_hint,
      hintStyle: WidgetStateProperty.all<TextStyle>(hintTextStyle),

    );
  }
}
