import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/models/closing_hours.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';

import 'package:meta/meta.dart';

part 'closing_hours_event.dart';
part 'closing_hours_state.dart';

class ClosingHoursBloc extends Bloc<ClosingHoursEvent, ClosingHoursState> {
  final UserDataRepository userDataRepository;
  ClosingHoursBloc({this.userDataRepository}) : super(ClosingHoursInitial());

  @override
  Stream<ClosingHoursState> mapEventToState(
    ClosingHoursEvent event,
  ) async* {
    if (event is GetAllClosingHours) {
      yield* mapGetAllClosingHoursToState();
    }
    if (event is UpdateClosingHours) {
      yield* mapUpdateClosingHoursEventToState(event.map);
    }
  }

  Stream<ClosingHoursState> mapGetAllClosingHoursToState() async* {
    yield GetAllClosingHoursInProgressState();
    try {
      ClosingHours closingHours = await userDataRepository.getClosingHours();
      if (closingHours != null) {
        yield GetAllClosingHoursCompletedState(closingHours);
      } else {
        yield GetAllClosingHoursFailedState();
      }
    } catch (e) {
      print(e);
      yield GetAllClosingHoursFailedState();
    }
  }

  Stream<ClosingHoursState> mapUpdateClosingHoursEventToState(
      ClosingHours map) async* {
    yield UpdateClosingHoursInProgressState();
    try {
      bool isUpdated = await userDataRepository.updateClosingHours(map);
      if (isUpdated) {
        yield UpdateClosingHoursCompletedState();
      } else {
        yield UpdateClosingHoursFailedState();
      }
    } catch (e) {
      print(e);
      yield UpdateClosingHoursFailedState();
    }
  }
}
