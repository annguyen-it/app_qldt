import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tab_repository/screen_repository.dart';

part 'screen_event.dart';

part 'screen_state.dart';

class ScreenBloc extends Bloc<ScreenEvent, ScreenState> {
  final ScreenRepository _screenRepository;

  ScreenBloc({@required ScreenRepository screenRepository})
      : assert(screenRepository != null),
        _screenRepository = screenRepository,
        super(ScreenState.defaultPage()){
    _screenRepository.changeTab(ScreenState.defaultPage().screenPage);
  }

  @override
  Stream<ScreenState> mapEventToState(
    ScreenEvent event,
  ) async* {
    if (event is ScreenPageChanged){
      _mapScreenPageChangedToState(event);
    }
  }

  ScreenState _mapScreenPageChangedToState(
      ScreenPageChanged event,
      ) {
    switch (event.screenPage){
      case ScreenPage.home:
        return const ScreenState.home();

      case ScreenPage.notification:
        return const ScreenState.notification();

      default:
        return const ScreenState.defaultPage();
    }
  }
}
