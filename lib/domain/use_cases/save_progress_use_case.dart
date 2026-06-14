import 'package:algoquest/domain/entities/user_progress.dart';

import 'package:algoquest/domain/repositories/user_repository.dart';

class SaveProgressUseCase {
  final UserRepository _userRepository;

  SaveProgressUseCase(this._userRepository);

  Future<void> call(UserProgress progress) {
    return _userRepository.updateUserProgress(progress);
  }
}
