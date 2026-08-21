import 'package:kwentappflutter/data/models/profile.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    this.isSavingName = false,
    this.isChangingAvatar = false,
  });

  final Profile profile;
  final bool isSavingName;
  final bool isChangingAvatar;

  bool get isBusy => isSavingName || isChangingAvatar;

  ProfileLoaded copyWith({
    Profile? profile,
    bool? isSavingName,
    bool? isChangingAvatar,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isSavingName: isSavingName ?? this.isSavingName,
      isChangingAvatar: isChangingAvatar ?? this.isChangingAvatar,
    );
  }
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}
