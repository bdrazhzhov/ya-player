import 'package:flutter/material.dart';

/// A list of [ValueNotifier]s.
/// This is a convenience type for working with multiple [ValueNotifier]s.
typedef ListValueNotifier = List<ValueNotifier>;

/// A function that builds a widget depending on the values of a list of [ValueNotifier]s.
extension ListValueNotifierExtension on ListValueNotifier {
  void addListenerToAll(VoidCallback listener) {
    for (var listenable in this) {
      listenable.addListener(listener);
    }
  }

  void removeListenerFromAll(VoidCallback listener) {
    for (var listenable in this) {
      listenable.removeListener(listener);
    }
  }

  T get<T>() => map((i) => i.value).whereType<T>().first;
}

/// A widget that listens to multiple [ValueNotifier]s and rebuilds when any of them change.
///
/// The [MultiValueListenableBuilder] takes a list of [ValueNotifier]s and a [builder] function.
/// The [builder] function is called whenever any of the [ValueNotifier]s in the list change.
/// The [builder] function is passed the current context, a list of the current values of the
/// [ValueNotifier]s, and an optional child widget.
///
/// This widget is useful when you need to listen to multiple [ValueNotifier]s and rebuild
/// the UI whenever any of them change.
///
/// Example usage:
/// ```dart
/// MultiValueListenableBuilder(
///   valuesListenable: [notifier1, notifier2],
///   builder: (context, values, child) {
///     return Column(
///       children: [
///         Text('Value 1: ${values[0]}'),
///         Text('Value 2: ${values[1]}'),
///       ],
///     );
///   },
/// )
/// ```
///
/// See also:
///  * [ValueNotifier], which is a [ChangeNotifier] that holds a single value.
///  * [ValueListenableBuilder], which is a widget that listens to a single [ValueNotifier].
class MultiValueListenableBuilder extends StatefulWidget {
  const MultiValueListenableBuilder({
    super.key,
    required this.valuesListenable,
    required this.builder,
    this.listenable,
    this.child,
  });

  /// The list of [ValueNotifier]s to listen to.
  /// The [builder] function will be called whenever any of the [ValueNotifier]s in this list change.
  final ListValueNotifier valuesListenable;

  /// The builder function that is called whenever any of the [ValueNotifier]s change.
  /// The function is passed the current [BuildContext], a list of the current values of the
  /// [ValueNotifier]s, and an optional child widget.
  /// The function must return a widget.
  final ValueWidgetBuilder<ListValueNotifier> builder;

  /// The listenable function that is called whenever any of the [ValueNotifier]s change.
  /// The function is passed the current [ListValueNotifier].
  /// The function must return a widget.
  final void Function(ListValueNotifier)? listenable;

  /// The child widget that is passed to the [builder] function.
  /// This can be used to pass a child widget to the [builder] function.
  /// The [child] widget is optional.
  /// If no [child] widget is passed, the [child] parameter of the [builder] function will be null.
  /// If a [child] widget is passed, the [child] parameter of the [builder] function will be the [child] widget.
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _MultiValueListenableBuilderState();
}

class _MultiValueListenableBuilderState
    extends State<MultiValueListenableBuilder> {
  @override
  void initState() {
    super.initState();
    _addListener();
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener();
  }

  void _notify() {
    widget.listenable?.call(widget.valuesListenable);
    setState(() {});
  }

  void _addListener() => widget.valuesListenable.addListenerToAll(_notify);

  void _removeListener() =>
      widget.valuesListenable.removeListenerFromAll(_notify);

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.valuesListenable,
      widget.child,
    );
  }
}
