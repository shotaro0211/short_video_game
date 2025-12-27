# ランキングチャレンジ

ランダムに出題されるアイテムを1位〜10位に配置していくソロゲームアプリ。

YouTube Shortsで人気の「プロ野球スター選手ランキング」企画を、一人でも楽しめるようにアプリ化。

## スクリーンショット

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   ホーム画面     │  │   ゲーム画面     │  │   結果画面      │
│                 │  │                 │  │                 │
│  ⚾ プロ野球    │  │  「大谷翔平」    │  │  🎉 完成！      │
│  ⚽ サッカー    │  │                 │  │                 │
│  🎌 アニメ     │  │  1位 [    ]     │  │  1位 大谷翔平   │
│  🍜 ラーメン   │  │  2位 [    ]     │  │  2位 ...        │
│                 │  │  ...           │  │                 │
│                 │  │  10位 [    ]    │  │  [シェア][ホーム]│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 遊び方

1. ホーム画面でジャンルを選ぶ
2. 出題されるアイテムを見て、1位〜10位のどこに配置するか決める
3. スロットをタップして配置（一度配置したら変更不可）
4. 10個すべて配置したらゲーム終了
5. 結果をシェアして友達と比較しよう！

## 対応ジャンル

| ジャンル | 内容 |
|---------|------|
| ⚾ プロ野球選手 | 大谷翔平、山本由伸、村上宗隆など |
| ⚽ サッカー選手 | メッシ、三笘薫、久保建英など |
| 🎌 アニメキャラ | 孫悟空、ルフィ、炭治郎など |
| 🍜 ラーメン店 | 一蘭、一風堂、天下一品など |

## セットアップ

### 必要環境

- Flutter 3.x
- Dart 3.x
- Xcode (iOS)
- Android Studio (Android)

### インストール

```bash
# 依存関係をインストール
flutter pub get

# アプリを起動
flutter run
```

### ビルド

```bash
# iOS
flutter build ios

# Android
flutter build apk
```

## 技術スタック

- **Flutter** - クロスプラットフォームUI
- **Riverpod** - 状態管理
- **share_plus** - SNSシェア機能

## ディレクトリ構成

```
lib/
├── main.dart              # エントリーポイント
├── models/
│   ├── genre.dart         # ジャンルモデル
│   ├── item.dart          # アイテムモデル
│   └── game_state.dart    # ゲーム状態モデル
├── screens/
│   ├── home_screen.dart   # ホーム画面
│   ├── game_screen.dart   # ゲーム画面
│   └── result_screen.dart # 結果画面
├── widgets/
│   ├── genre_card.dart    # ジャンル選択カード
│   ├── item_card.dart     # アイテム表示カード
│   └── ranking_slot.dart  # ランキングスロット
├── providers/
│   └── game_provider.dart # ゲーム状態管理
└── data/
    └── sample_data.dart   # サンプルデータ
```

## カスタマイズ

### 新しいジャンルを追加する

`lib/data/sample_data.dart` を編集:

```dart
// 1. genresリストに追加
const Genre(
  id: 'new_genre',
  name: '新ジャンル',
  emoji: '🆕',
  color: Color(0xFF...),
  description: '説明文',
),

// 2. itemsByGenreに追加
'new_genre': [
  const Item(id: 'n1', name: 'アイテム1', genreId: 'new_genre', popularityScore: 100),
  // ... 最低10個以上
],
```

## ライセンス

MIT License
