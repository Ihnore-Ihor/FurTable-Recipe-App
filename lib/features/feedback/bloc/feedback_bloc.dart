import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class FeedbackEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SubmitFeedback extends FeedbackEvent {
  final String text;
  SubmitFeedback(this.text);
}

// States
abstract class FeedbackState extends Equatable {
  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {}

class FeedbackFailure extends FeedbackState {
  final String error;
  FeedbackFailure(this.error);
}

// BLoC
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc() : super(FeedbackInitial()) {
    on<SubmitFeedback>((event, emit) async {
      emit(FeedbackLoading());
      try {
        await Future.delayed(const Duration(seconds: 1)); // Імітація
        emit(FeedbackSuccess());
      } catch (e) {
        emit(FeedbackFailure("Failed to send feedback"));
      }
    });
  }
}
