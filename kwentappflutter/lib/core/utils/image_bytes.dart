import 'dart:typed_data';

const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
const _jpeg = [0xFF, 0xD8, 0xFF];

String? imageExtensionFor(Uint8List bytes) {
  if (_startsWith(bytes, _png)) return 'png';
  if (_startsWith(bytes, _jpeg)) return 'jpg';
  return null;
}

bool _startsWith(Uint8List bytes, List<int> signature) {
  if (bytes.length < signature.length) return false;

  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return false;
  }

  return true;
}
