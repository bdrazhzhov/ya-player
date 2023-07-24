import 'package:flutter/material.dart';

class PageBaseLayout extends StatelessWidget {
  final String? title;
  final Widget body;

  const PageBaseLayout({super.key, required this.body, this.title});

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if(title != null) {
      appBar = AppBar(
        leading: (ModalRoute.of(context)?.canPop ?? false) ? const BackButton() : null,
        title: Text(title!),
      );
    }

    return Scaffold(
      // appBar: appBar,
      body: body,
    );
  }
}