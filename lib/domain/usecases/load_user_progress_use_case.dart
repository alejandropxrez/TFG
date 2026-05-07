import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';

class LoadUserProgressUseCase {
  final UserRepository _userRepository;

  LoadUserProgressUseCase(this._userRepository);

  Future<UserProgress?> call(String userId) {
    return _userRepository.fetchUserProgress(userId);
  }
}
