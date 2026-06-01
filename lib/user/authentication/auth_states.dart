abstract class AuthStates {}

class AuthInitialState extends AuthStates {}
class AuthUpdateState extends AuthStates {}

class AuthAuthenticatedState extends AuthStates {}
class AuthLoadingState extends AuthStates {}
class AuthUnauthenticatedState extends AuthStates {}

// Password
class PasswordVisibilityState extends AuthStates {}
class PasswordStrengthState extends AuthStates {
  final String password;
  final int strength;
  final String strengthLabel;

  PasswordStrengthState({
    required this.password,
    required this.strength,
    required this.strengthLabel,
  });
}

// Register
class RegisterLoadingState extends AuthStates {}
class RegisterSuccessState extends AuthStates {}
class RegisterErrorState extends AuthStates {
  final String error;

  RegisterErrorState({required this.error});
}

// Login 
class LoginLoadingState extends AuthStates {}
class LoginErrorState extends AuthStates {
  final String error;

  LoginErrorState({required this.error});
}

// Logout
class LogoutLoadingState extends AuthStates {}
class LogoutErrorState extends AuthStates {
  final String error;

  LogoutErrorState({required this.error});
}
