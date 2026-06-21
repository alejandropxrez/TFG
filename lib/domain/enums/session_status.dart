/// Lifecycle status of a challenge session.
enum SessionStatus {
  /// The user is currently interacting with the challenge.
  inProgress,

  /// The challenge has been solved successfully.
  completed,

  /// The challenge has been evaluated as unsuccessful.
  failed,
}
