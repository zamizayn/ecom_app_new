import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendOtpRequested(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String otp;
  const VerifyOtpRequested(this.otp);
  @override
  List<Object> get props => [otp];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phoneNumber;
  const OtpSent(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String? _pendingPhoneNumber;

  AuthBloc() : super(AuthInitial()) {
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      if (event.phoneNumber.length >= 10) {
        _pendingPhoneNumber = event.phoneNumber;
        emit(OtpSent(event.phoneNumber));
      } else {
        emit(const AuthError('Invalid phone number'));
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      if (event.otp.length == 6) {
        // Accept any 4 digit code for mock
        emit(Authenticated());
      } else {
        // Fall back to OtpSent so UI doesn't break back out to login entirely if we wanted that,
        // but for simplicity, we'll just emit an error.
        emit(const AuthError('Invalid OTP Code'));
        if (_pendingPhoneNumber != null) {
          emit(OtpSent(_pendingPhoneNumber!));
        }
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      _pendingPhoneNumber = null;
      emit(Unauthenticated());
    });
  }
}
