import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:furtable/features/profile/repositories/feedback_repository.dart';

/// Abstract base class for feedback events.
abstract class FeedbackEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event triggered when the user submits feedback.
class SubmitFeedback extends FeedbackEvent {
  /// The feedback text content.
  final String text;

  /// Creates a [SubmitFeedback] event.
  SubmitFeedback(this.text);

  @override
  List<Object> get props => [text];
}

/// Abstract base class for feedback states.
abstract class FeedbackState extends Equatable {
  @override
  List<Object> get props => [];
}

/// Initial state of the feedback process.
class FeedbackInitial extends FeedbackState {}

/// State indicating that feedback is being submitted.
class FeedbackLoading extends FeedbackState {}

/// State indicating that feedback was successfully submitted.
class FeedbackSuccess extends FeedbackState {}

/// State indicating that an error occurred while submitting feedback.
class FeedbackFailure extends FeedbackState {
  /// The error message.
  final String error;

  /// Creates a [FeedbackFailure] with the given error message.
  FeedbackFailure(this.error);

  @override
  List<Object> get props => [error];
}

/// Manages the state of the feedback submission process.
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _repo = FeedbackRepository();

  /// Creates a [FeedbackBloc].
  FeedbackBloc() : super(FeedbackInitial()) {
    on<SubmitFeedback>((event, emit) async {
      emit(FeedbackLoading());
      try {
        await _repo.sendFeedback(event.text);
        emit(FeedbackSuccess());
      } catch (e) {
        emit(FeedbackFailure("Failed to send feedback: $e"));
      }
    });
  }
}
