import 'package:flutter/widgets.dart';

Type _typeOf<T>() => T;

abstract class BlocBase {
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key,
    Widget child,
    T bloc
  }) : assert(child != null),
    assert(bloc != null),
    _child = child,
    _bloc = bloc,
    super(key: key);

  final Widget _child;
  Widget get child => _child;

  final T _bloc;
  T get bloc => _bloc;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOf<_BlocProviderInherited<T>>();
    _BlocProviderInherited<T> provider = context.ancestorInheritedElementForWidgetOfExactType(type).widget;
    return provider.bloc;
  }
}

class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>> {
  @override
  void dispose() {
    debugPrint('${widget.runtimeType.toString()} dispose');
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${widget.runtimeType.toString()} build');
    return Container(
      child: _BlocProviderInherited<T>(
        child: widget.child,
        bloc: widget.bloc,
      ),
    );
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({
    Key key,
    Widget child,
    T bloc
  }) : assert(child != null),
    assert(bloc != null),
      _bloc = bloc,
      super(key: key, child: child);

  final T _bloc;
  T get bloc => _bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited old) => this != old;
}