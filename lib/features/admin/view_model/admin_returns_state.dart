import '../../financial_returns/model/financial_return.dart';

/// One-shot message for the snack bar after a write.
class AdminFeedback {
  const AdminFeedback(this.message, {this.isError = false});

  final String message;
  final bool isError;
}

/// States of the admin returns page.
sealed class AdminReturnsState {
  const AdminReturnsState();
}

final class AdminReturnsInitial extends AdminReturnsState {
  const AdminReturnsInitial();
}

final class AdminReturnsLoading extends AdminReturnsState {
  const AdminReturnsLoading();
}

final class AdminReturnsLoaded extends AdminReturnsState {
  const AdminReturnsLoaded({required this.rows, this.feedback});

  final List<FinancialReturn> rows;

  /// Transient result of the last write; the view shows it then clears it.
  final AdminFeedback? feedback;

  AdminReturnsLoaded withFeedback(AdminFeedback? value) =>
      AdminReturnsLoaded(rows: rows, feedback: value);
}

final class AdminReturnsFailure extends AdminReturnsState {
  const AdminReturnsFailure({required this.message});

  final String message;
}
