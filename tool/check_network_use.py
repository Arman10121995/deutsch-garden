#!/usr/bin/env python3
"""Fails the build if the app grows a second way of reaching the network.

"Fully offline" is the project's oldest promise and the easiest one to lose by
accident: one convenience call to fetch a definition, one crash reporter, one
analytics package added to solve a real problem, and the claim in the README
quietly stops being true. Nobody notices, because nothing breaks.

So it is checked rather than remembered. Exactly one file is allowed to open a
socket -- the optional speech-model download, which the learner asks for by
name -- and even that file has to keep saying where the model comes from and
under what licence, because CC-BY-4.0 requires the attribution to travel with
it.

Run: python tool/check_network_use.py
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"

# The single exception, and why it is one.
ALLOWED = {
    "asr_io.dart": (
        "the optional speech model download: opt-in, once, and never again "
        "(see lib/asr.dart)"
    ),
}

# Things that reach off the device. Matched as source text rather than by
# parsing, deliberately: this should fire on a commented-out experiment too,
# because those get uncommented.
OUTBOUND = [
    (r"\bHttpClient\b", "dart:io HttpClient"),
    (r"package:http/", "the http package"),
    (r"package:dio/", "the dio package"),
    (r"\bWebSocket\b", "a WebSocket"),
    (r"\bInternetAddress\b", "a DNS/socket lookup"),
    (r"\bSocket\.connect\b", "a raw socket"),
    (r"\blaunchUrl\b", "url_launcher"),
    (r"HttpRequest", "dart:html HttpRequest"),
    (r"\bwindow\.fetch\b", "fetch()"),
]

# Packages that would mean the app talks to somebody. Checked in the manifest
# as well as in the source, because a dependency arrives before its first use.
BANNED_PACKAGES = [
    "http:",
    "dio:",
    "firebase_",
    "google_sign_in",
    "sentry",
    "posthog",
    "amplitude",
    "mixpanel",
    "url_launcher",
]

# Hosts the one allowed download may use. GitHub Releases is where the k2-fsa
# project publishes; anything else is a supply chain nobody reviewed.
ALLOWED_HOSTS = ("https://github.com/k2-fsa/",)


def main() -> int:
    problems: list[str] = []

    for path in sorted(LIB.rglob("*.dart")):
        text = path.read_text(encoding="utf-8")
        name = path.name
        for pattern, human in OUTBOUND:
            if not re.search(pattern, text):
                continue
            if name in ALLOWED:
                continue
            rel = path.relative_to(ROOT).as_posix()
            problems.append(
                f"{rel} uses {human}. This app is offline. If a download is "
                f"genuinely the only way, it belongs behind the same opt-in "
                f"the speech model uses, and this list has to be widened on "
                f"purpose."
            )

    # Every URL in the source, wherever it lives, must be one we chose.
    for path in sorted(LIB.rglob("*.dart")):
        text = path.read_text(encoding="utf-8")
        for url in re.findall(r"https?://[^\s'\"]+", text):
            if url.startswith("http://") and "://localhost" not in url:
                problems.append(
                    f"{path.relative_to(ROOT).as_posix()} names a plaintext "
                    f"http:// URL: {url}"
                )
            elif url.startswith("https://") and not url.startswith(
                ALLOWED_HOSTS
            ):
                # Doc comments cite sources; only strings that could be
                # fetched matter, and those live in const declarations.
                line = next(
                    (
                        candidate
                        for candidate in text.splitlines()
                        if url in candidate
                    ),
                    "",
                )
                if not line.lstrip().startswith("///") and not line.lstrip().startswith("//"):
                    problems.append(
                        f"{path.relative_to(ROOT).as_posix()} names an "
                        f"unapproved URL in code: {url}"
                    )

    # The exception has to keep its bargain.
    asr = (LIB / "asr_io.dart").read_text(encoding="utf-8")
    if "modelUrl" not in asr:
        problems.append("lib/asr_io.dart no longer declares modelUrl.")
    if "CC-BY-4.0" not in asr:
        problems.append(
            "lib/asr_io.dart no longer states the model's licence. CC-BY-4.0 "
            "requires the attribution to travel with the file."
        )
    if "learner speech will be worse" not in asr:
        problems.append(
            "lib/asr_io.dart no longer carries the accuracy caveat. 5.1% word "
            "error rate is native read speech; a learner told a correct answer "
            "is wrong is worse off than with no transcript at all."
        )

    # Android's guarantee is the strongest one this project has, because the
    # OS enforces it rather than the maintainer remembering to. It is also the
    # one now under pressure: the speech model would run fine on a phone and
    # only the missing permission stops it. Adding INTERNET "just for the
    # download" would hand the guarantee back for every learner who never
    # opens that setting.
    manifest_patch = (ROOT / "tool" / "patch_android_manifest.py").read_text(
        encoding="utf-8"
    )
    permissions = re.search(
        r"PERMISSIONS = \[(.*?)\]", manifest_patch, re.DOTALL
    )
    if permissions is None:
        problems.append(
            "tool/patch_android_manifest.py no longer declares a PERMISSIONS "
            "list, so the Android permission set is unchecked."
        )
    elif "INTERNET" in permissions.group(1):
        problems.append(
            "tool/patch_android_manifest.py requests INTERNET. The Android "
            "build's offline promise is enforced by the OS precisely because "
            "this permission is absent; the speech model is desktop-only for "
            "that reason (lib/asr_io.dart)."
        )

    manifest = ROOT / "android" / "app" / "src" / "main" / "AndroidManifest.xml"
    if manifest.exists() and "android.permission.INTERNET" in manifest.read_text(
        encoding="utf-8"
    ):
        problems.append(
            "android/app/src/main/AndroidManifest.xml requests INTERNET."
        )

    # And the code has to keep agreeing: a recogniser that reports itself
    # supported on Android would show a download button that cannot work.
    asr_supported = re.search(
        r"bool get isSupported =>(.*?);", asr, re.DOTALL
    )
    if asr_supported and re.search(
        r"isAndroid|isIOS", asr_supported.group(1)
    ):
        problems.append(
            "lib/asr_io.dart offers the download on a platform with no "
            "network permission. The button would fail on a learner's phone."
        )

    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    # Only the dependency blocks; the description may say anything.
    for line in pubspec.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        for banned in BANNED_PACKAGES:
            if stripped.startswith(banned):
                problems.append(
                    f"pubspec.yaml depends on '{stripped}', which talks to "
                    f"somebody. This app does not."
                )

    if problems:
        print("Network-use check failed:\n")
        for problem in problems:
            print(f"  - {problem}")
        print(
            "\nThe only sanctioned outbound call is:\n"
            + "\n".join(f"  {k}: {v}" for k, v in ALLOWED.items())
        )
        return 1

    allowed = ", ".join(ALLOWED)
    print(
        f"Network-use check passed: {allowed} is the only file that can reach "
        f"the network, and it still states its licence and its caveat."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
