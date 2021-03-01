part of 'closing_hours_bloc.dart';

@immutable
abstract class ClosingHoursEvent {}

class GetAllClosingHours extends ClosingHoursEvent {}

class UpdateClosingHours extends ClosingHoursEvent {
  final ClosingHours map;

  UpdateClosingHours(this.map);
}
