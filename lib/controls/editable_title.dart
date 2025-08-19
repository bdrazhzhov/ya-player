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
  bool showEditIcon = false;
  late String oldText = widget.title;
  late final controller = TextEditingController(text: widget.title);

  @override
  Widget build(BuildContext context) {
    final TextStyle? style =
        Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold);

    if (widget.onSubmitted == null) {
      return buildTitleText(style);
    }

    return SizedBox(
      height: 64,
      child: Align(
        alignment: Alignment.centerLeft,
        child: isEditing ? buildTextField(style) : buildEditableTitle(style),
      ),
    );
  }

  GestureDetector buildEditableTitle(TextStyle? style) {
    return GestureDetector(
      onTap: () => setState(() {
        isEditing = true;
        oldText = controller.text;
      }),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: buildTitleText(style),
      ),
    );
  }

  Focus buildTextField(TextStyle? style) {
    return Focus(
      onKeyEvent: onKeyEvent,
      onFocusChange: (hasFocus) {
        if (!hasFocus && isEditing) cancelEdit();
      },
      child: TextField(
        controller: controller,
        autofocus: true,
        style: style,
        onSubmitted: submit,
      ),
    );
  }

  Widget buildTitleText(TextStyle? style) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

      final tp = TextPainter(
        text: TextSpan(text: controller.text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.of(context).textScaler,
        maxLines: 1,
      );

      tp.layout(maxWidth: constraints.maxWidth);
      final textWidget = Text(controller.text, style: effectiveStyle, overflow: TextOverflow.ellipsis);

      if(tp.didExceedMaxLines) {
        return Tooltip(
          message: controller.text,
          child: textWidget,
        );
      }

      return textWidget;
    });
  }

  void submit(String value) {
    setState(() => isEditing = false);
    oldText = value;
    widget.onSubmitted?.call(value);
  }

  void cancelEdit() {
    setState(() => isEditing = false);
    controller.text = oldText;
  }

  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      cancelEdit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
