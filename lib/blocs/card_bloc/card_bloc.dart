import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'card_event.dart';
part 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final UserDataRepository userDataRepository;

  CardBloc({this.userDataRepository}) : super(null);
  @override
  CardState get initialState => CardInitial();

  @override
  Stream<CardState> mapEventToState(
    CardEvent event,
  ) async* {
    if (event is AddCardEvent) {
      yield* mapAddCardEventToState(event.card);
    }
    if (event is EditCardEvent) {
      yield* mapEditCardEventToState(event.card, event.index);
    }
    if (event is DeleteCardEvent) {
      yield* mapDeleteCardEventToState(event.card, event.index);
    }
    if (event is GetAllCardsEvent) {
      yield* mapGetAllCardsEventToState();
    }
  }

  Stream<CardState> mapAddCardEventToState(Map<String, dynamic> card) async* {
    yield AddCardInProgressState();
    try {
      bool isAdded = await userDataRepository.addCard(card);
      if (isAdded) {
        yield AddCardCompletedState();
      } else {
        yield AddCardFailedState();
      }
    } catch (e) {
      print(e);
      yield AddCardFailedState();
    }
  }

  Stream<CardState> mapEditCardEventToState(
      Map<String, dynamic> card, int index) async* {
    yield EditCardInProgressState();
    try {
      bool isEdited = await userDataRepository.editCard(card, index);
      if (isEdited) {
        yield EditCardCompletedState();
      } else {
        yield EditCardFailedState();
      }
    } catch (e) {
      print(e);
      yield EditCardFailedState();
    }
  }

  Stream<CardState> mapDeleteCardEventToState(
      Map<String, dynamic> card, int index) async* {
    yield DeleteCardInProgressState();
    try {
      bool isDeleted = await userDataRepository.deleteCard(card, index);
      if (isDeleted) {
        yield DeleteCardCompletedState();
      } else {
        yield DeleteCardFailedState();
      }
    } catch (e) {
      print(e);
      yield DeleteCardFailedState();
    }
  }

  Stream<CardState> mapGetAllCardsEventToState() async* {
    yield GetAllCardsInProgressState();
    try {
      List cardsList = await userDataRepository.getAllCards();
      if (cardsList != null) {
        yield GetAllCardsCompletedState(cardsList);
      } else {
        yield GetAllCardsFailedState();
      }
    } catch (e) {
      print(e);
      yield GetAllCardsFailedState();
    }
  }
}
