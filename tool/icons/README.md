# Launcher icon configuration

One config per platform, because the native wrappers are generated at build
time and each CI job generates exactly one of them. A single combined config in
`pubspec.yaml` fails the moment it is asked for a platform whose directory does
not exist — which is every job except one.

Run the one matching what `flutter create` just generated:

```bash
dart run flutter_launcher_icons -f tool/icons/android.yaml
```

Linux has no entry: `flutter_launcher_icons` does not support it, and a Linux
desktop icon is supplied by the `.desktop` file at packaging time instead.
