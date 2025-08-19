import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableTitle extends StatefulWidget {
  final String title;
  final void Function(String)? onSubmitted;

  const EditableTitle({super.key, required this.title, this.onSubmitted});

  @override
  State<EditableTitle> createState() => _EditableTitleState();
}

class _EditableTitleState extends State<EditableTitle> {
  bool isEditing = false;
  late String oldText = widget.title;
  late final controller = TextEditingController(text: widget.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(widget.onSubmitted != null) {
      if(isEditing) {
        return Focus(
          onKeyEvent: onKeyEvent,
          child: SizedBox(
            height: 64,
            width: 500,
            child: TextField(
              autofocus: true,
              controller: controller,
              style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
              onSubmitted: onSubmitted,
            ),
          ),
        );
      }

      return Row(
        children: [
          buildTitleLabel(),
          IconButton(
            onPressed: onEditPress,
            icon: const Icon(Icons.edit),
          ),
        ],
      );
    }

    return buildTitleLabel();
  }

  Text buildTitleLabel() {
    return Text(
      controller.text,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }
  
  void onEditPress() {
    isEditing = true;
    oldText = controller.text;
    setState(() {});
  }

  void onSubmitted(String newValue) {
    isEditing = false;
    oldText = newValue;
    setState(() {});
    widget.onSubmitted?.call(newValue);
  }

  void onEditCanceled() {
    isEditing = false;
    controller.text = oldText;
    setState(() {});
  }

  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    if(event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      isEditing = false;
      controller.text = oldText;
      setState(() {});
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
