# build-release

リリースビルドを作成するスキル。

## 使い方

```
/build-release [platform]
```

## iOS

```bash
# コード署名なし（テスト用）
flutter build ios --no-codesign

# リリース用
flutter build ios --release

# App Store用
flutter build ipa
```

出力: `build/ios/iphoneos/Runner.app`

## Android

```bash
# APK
flutter build apk --release

# App Bundle (推奨)
flutter build appbundle --release
```

出力:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 事前チェック

```bash
# コード分析
flutter analyze

# テスト実行
flutter test
```

## アプリ情報の変更

- アプリ名: `android/app/src/main/AndroidManifest.xml` / `ios/Runner/Info.plist`
- バージョン: `pubspec.yaml` の `version`
- アイコン: `flutter_launcher_icons` パッケージを使用
