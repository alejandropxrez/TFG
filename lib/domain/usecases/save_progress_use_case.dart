import '../entities/user_progress.dart';
import '../repositories/user_repository.dart';

class SaveProgressUseCase {
  final UserRepository _userRepository;

  SaveProgressUseCase(this._userRepository);

  Future<void> call(UserProgress progress) {
    return _userRepository.updateUserProgress(progress);
  }
}
