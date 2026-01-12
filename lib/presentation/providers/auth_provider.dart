import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';

/// Authentication State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      username: username ?? this.username,
    );
  }
}

/// Authentication Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple authentication check
    if (username == Constants.defaultUsername &&
        password == Constants.defaultPassword) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: username,
      );
      return true;
    } else {
      state = state.copyWith(
        error: Constants.errorInvalidCredentials,
        isLoading: false,
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
