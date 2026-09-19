import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class SimpleBlocObserver extends BlocObserver {


  @override
  void onTransition(Bloc bloc, Transition transition) {
    // TODO: implement onTransition
    if (kDebugMode) {
      print(transition);
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    // TODO: implement onChange
    if (kDebugMode) {
      print(change);
    }
    super.onChange(bloc, change);
  }



}