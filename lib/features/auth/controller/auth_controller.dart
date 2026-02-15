import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadup/Core/utile.dart';
import 'package:threadup/features/auth/repository/auth_repository.dart';
import 'package:threadup/features/models/user_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref)=>AuthController(authRepository: ref.watch(authRepositoryProvider), ref: ref));
final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  
  void signInWithGoogle(BuildContext context) async {
    state  =  true;
    final result = await _authRepository.signInWithGoogle();
    state  = false;
     result.fold((l) => showSnackBar(context,l.message), (UserModel) => _ref.read(userProvider.notifier).update((state) => UserModel));
  }
}