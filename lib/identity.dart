/// Who the learner is, as far as this device is concerned.
///
/// A name, an optional email address and an optional picture. None of it
/// leaves the device, none of it is an account, and nothing in the app
/// requires any of it — the fields exist so a profile screen feels like the
/// learner's rather than a stranger's.
///
/// That is worth being plain about, because an app that asks for an email
/// address usually does so to send something somewhere. This one has no
/// server to send it to. The field is stored beside the streak count and is
/// read by nothing.
///
/// The picture lives under its own storage key rather than inside the profile
/// blob. A 256-pixel avatar is tens of kilobytes; carrying that through every
/// re-encode of the profile would undo a good part of what debouncing the
/// writes bought.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// The longest side an avatar is stored at.
///
/// Large enough for a 96-pixel circle on a high-density screen, small enough
/// that the stored string stays in the tens of kilobytes. A learner picking a
/// twelve-megapixel photograph should not be storing a twelve-megapixel
/// photograph.
const int avatarMaxEdge = 256;

/// Refuses anything that is not a picture, and anything absurd.
///
/// The decoder is the check: a file that does not decode is not an image,
/// whatever its extension says.
const int avatarMaxSourceBytes = 20 * 1024 * 1024;

class AvatarResult {
  const AvatarResult({this.bytes, this.error});

  final Uint8List? bytes;
  final String? error;

  bool get ok => bytes != null;
}

/// Decodes [source], squares it off and shrinks it to [avatarMaxEdge].
///
/// Returns a PNG, or an explanation. Deliberately total: a learner picking the
/// wrong file gets a sentence, not an exception.
AvatarResult prepareAvatar(Uint8List source) {
  if (source.isEmpty) {
    return const AvatarResult(error: 'That file is empty.');
  }
  if (source.length > avatarMaxSourceBytes) {
    return const AvatarResult(
        error: 'That image is very large. Try one under 20 MB.');
  }
  img.Image? decoded;
  try {
    decoded = img.decodeImage(source);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    return const AvatarResult(error: 'That file is not an image this app can '
        'read. PNG and JPEG both work.');
  }

  // Square from the centre before resizing, so a portrait photograph becomes a
  // face rather than a face with the top of the head missing.
  final int edge = decoded.width < decoded.height
      ? decoded.width
      : decoded.height;
  final img.Image squared = img.copyCrop(
    decoded,
    x: ((decoded.width - edge) / 2).round(),
    y: ((decoded.height - edge) / 2).round(),
    width: edge,
    height: edge,
  );
  final img.Image scaled = edge > avatarMaxEdge
      ? img.copyResize(squared,
          width: avatarMaxEdge,
          height: avatarMaxEdge,
          interpolation: img.Interpolation.average)
      : squared;

  return AvatarResult(bytes: Uint8List.fromList(img.encodePng(scaled)));
}

/// Whether [value] could plausibly be an email address.
///
/// Deliberately loose. The app never sends anything to it, so the only purpose
/// of checking is to catch a typo the learner would want to know about, and a
/// strict pattern rejects addresses that are perfectly valid.
bool looksLikeEmail(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return true;
  return RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(trimmed);
}

String encodeAvatar(Uint8List bytes) => base64Encode(bytes);

Uint8List? decodeAvatar(String value) {
  if (value.isEmpty) return null;
  try {
    return base64Decode(value);
  } catch (error) {
    debugPrint('stored avatar could not be decoded: $error');
    return null;
  }
}
