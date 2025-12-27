# run-app

アプリを起動するスキル。

## 使い方

```
/run-app [platform]
```

## プラットフォーム

- `ios` - iOSシミュレータで起動
- `android` - Androidエミュレータで起動
- `web` - Webブラウザで起動（要: flutter config --enable-web）

## コマンド

```bash
# デフォルト（接続されているデバイス）
flutter run

# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## トラブルシューティング

### デバイスが見つからない
```bash
flutter devices
```

### 依存関係エラー
```bash
flutter pub get
```

### ビルドエラー
```bash
flutter clean
flutter pub get
flutter run
```
