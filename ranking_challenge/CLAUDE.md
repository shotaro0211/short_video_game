# CLAUDE.md - 1位はどれだ？

## プロジェクト概要

YouTube Shortsで人気の「ランキング企画」を一人でも楽しめるFlutterアプリ。

## 技術スタック

- Flutter 3.x
- Riverpod (状態管理)
- share_plus (シェア機能)

## アーキテクチャ

```
lib/
├── models/      # データモデル（イミュータブル）
├── screens/     # 画面（ConsumerWidget）
├── widgets/     # 再利用可能なUIコンポーネント
├── providers/   # Riverpod Notifier
└── data/        # サンプルデータ
```

## コーディング規約

### Dart/Flutter
- クラス名: PascalCase
- 変数・関数名: camelCase
- ファイル名: snake_case
- constを積極的に使用
- StatelessWidget > StatefulWidget（可能な限り）

### 状態管理
- Riverpod 3.x の Notifier パターンを使用
- StateNotifierは非推奨（使用しない）

## よく使うコマンド

```bash
# 開発
flutter run

# ビルド
flutter build ios
flutter build apk

# 分析
flutter analyze

# テスト
flutter test
```

## ジャンル追加手順

1. `lib/data/sample_data.dart` の `genres` リストに Genre を追加
2. `itemsByGenre` マップに最低10個のアイテムを追加
3. `popularityScore` は 1-100 の範囲で設定（スコア計算に使用）

## 注意事項

- 各ジャンルには最低10個のアイテムが必要
- popularityScore が高いほど上位にランクされるべきアイテム
- 画像URLは現在未使用（将来の拡張用）
