/// Talking-Tom style interactive gesture triggers
enum CharacterGesture {
  headPat('Pat Head', '💆‍♀️'),
  cheekPoke('Poke Cheek', '🤏'),
  noseTap('Tap Nose', '👃'),
  poke('Poke', '👉'),
  hold('Gentle Hold', '🤲'),
  swipe('Swipe / Stroke', '👋'),
  tickle('Tickle', '✨');

  final String label;
  final String icon;
  const CharacterGesture(this.label, this.icon);
}
