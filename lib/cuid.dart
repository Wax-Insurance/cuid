import 'dart:io' as io;
import 'dart:math';

final String _prefix = 'c';
final int _base = 36; // size of the alphabet

String _timeBlock() {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  return now.toRadixString(_base);
}

final int _discreteValues = pow(_base, 4).toInt();
int _counter = 0;
String _counterBlock() {
  _counter = _counter < _discreteValues ? _counter : 0;
  _counter++;
  return _pad((_counter - 1).toRadixString(_base), 4);
}

final String _fingerprint = _pidFingerprint() + _hostFingerprint();

String _pidFingerprint() {
  return _pad(io.pid.toRadixString(_base), 2);
}

String _hostFingerprint() {
  final int hostId =
      io.Platform.localHostname.runes.reduce((acc, r) => acc + r);
  return _pad(hostId.toRadixString(_base), 2);
}

final _secureRandom = Random.secure();
String _secureRandomBlock() {
  const max = 1 << 32;
  return _pad(_secureRandom.nextInt(max).toRadixString(_base), 4);
}

String _pad(String s, int l) {
  s = s.padLeft(l, '0');
  return s.substring(s.length - l);
}

/// newCuid returns a short random string suitable for use as a unique identifier
String newCuid() {
  // time block (exposes exactly when id was generated, on purpose)
  final tblock = _timeBlock();

  // counter block
  final cblock = _counterBlock();

  // fingerprint block
  final fblock = _fingerprint;

  // random block
  final rblock = _secureRandomBlock() + _secureRandomBlock();

  return _prefix + tblock + cblock + fblock + rblock;
}

/// isCuid validates the supplied string is a cuid
bool isCuid(String? s) {
  s = s ?? '';
  return s.startsWith(_prefix);
}
