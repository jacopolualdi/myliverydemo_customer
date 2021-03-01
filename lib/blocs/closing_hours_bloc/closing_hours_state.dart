part of 'closing_hours_bloc.dart';

@immutable
abstract class ClosingHoursState {}

class ClosingHoursInitial extends ClosingHoursState {}

class GetAllClosingHoursInProgressState extends ClosingHoursState {}

class GetAllClosingHoursFailedState extends ClosingHoursState {}

class GetAllClosingHoursCompletedState extends ClosingHoursState {
  final ClosingHours closingHours;

  GetAllClosingHoursCompletedState(this.closingHours);
}

class UpdateClosingHoursInProgressState extends ClosingHoursState {}

class UpdateClosingHoursFailedState extends ClosingHoursState {}

class UpdateClosingHoursCompletedState extends ClosingHoursState {}
