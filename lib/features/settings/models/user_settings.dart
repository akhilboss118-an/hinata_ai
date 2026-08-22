import '../../../core/constants/app_constants.dart';

/// User and Companion Settings entity synchronized across devices
class UserSettings {
  final String characterName;
  final bool voiceEnabled;
  final String selectedVoice;
  final bool notificationEnabled;
  final String theme;
  final double kindness;
  final double playfulness;
  final double shyness;
  final double energy;

  const UserSettings({
    this.characterName = AppConstants.defaultCharacterName,
    this.voiceEnabled = true,
    this.selectedVoice = 'Warm Female',
    this.notificationEnabled = true,
    this.theme = 'dark_neon_violet',
    this.kindness = AppConstants.defaultKindness,
    this.playfulness = AppConstants.defaultPlayfulness,
    this.shyness = AppConstants.defaultShyness,
    this.energy = AppConstants.defaultEnergy,
  });

  Map<String, dynamic> toMap() {
    return {
      'characterName': characterName,
      'voiceEnabled': voiceEnabled,
      'selectedVoice': selectedVoice,
      'notificationEnabled': notificationEnabled,
      'theme': theme,
      'kindness': kindness,
      'playfulness': playfulness,
      'shyness': shyness,
      'energy': energy,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      characterName: map['characterName'] as String? ?? AppConstants.defaultCharacterName,
      voiceEnabled: map['voiceEnabled'] as bool? ?? true,
      selectedVoice: map['selectedVoice'] as String? ?? 'Warm Female',
      notificationEnabled: map['notificationEnabled'] as bool? ?? true,
      theme: map['theme'] as String? ?? 'dark_neon_violet',
      kindness: (map['kindness'] as num?)?.toDouble() ?? AppConstants.defaultKindness,
      playfulness: (map['playfulness'] as num?)?.toDouble() ?? AppConstants.defaultPlayfulness,
      shyness: (map['shyness'] as num?)?.toDouble() ?? AppConstants.defaultShyness,
      energy: (map['energy'] as num?)?.toDouble() ?? AppConstants.defaultEnergy,
    );
  }
}
