part of 'card_bloc.dart';

@immutable
abstract class CardState {}

class CardInitial extends CardState {}

class AddCardInProgressState extends CardState {
  @override
  String toString() => 'AddCardInProgressState';
}

class AddCardFailedState extends CardState {
  @override
  String toString() => 'AddCardFailedState';
}

class AddCardCompletedState extends CardState {
  @override
  String toString() => 'AddCardCompletedState';
}

class EditCardInProgressState extends CardState {
  @override
  String toString() => 'EditCardInProgressState';
}

class EditCardFailedState extends CardState {
  @override
  String toString() => 'EditCardFailedState';
}

class EditCardCompletedState extends CardState {
  @override
  String toString() => 'EditCardCompletedState';
}

class DeleteCardInProgressState extends CardState {
  @override
  String toString() => 'DeleteCardInProgressState';
}

class DeleteCardFailedState extends CardState {
  @override
  String toString() => 'DeleteCardFailedState';
}

class DeleteCardCompletedState extends CardState {
  @override
  String toString() => 'DeleteCardCompletedState';
}

class GetAllCardsInProgressState extends CardState {
  @override
  String toString() => 'GetAllCardsInProgressState';
}

class GetAllCardsFailedState extends CardState {
  @override
  String toString() => 'GetAllCardsFailedState';
}

class GetAllCardsCompletedState extends CardState {
  final List cardsList;

  GetAllCardsCompletedState(this.cardsList);

  @override
  String toString() => 'GetAllCardsCompletedState';
}
