# add-genre

新しいジャンルをゲームに追加するスキル。

## 使い方

```
/add-genre [ジャンル名]
```

## 手順

1. `lib/data/sample_data.dart` を開く
2. `genres` リストに新しい Genre を追加:
   ```dart
   const Genre(
     id: '[snake_case_id]',
     name: '[ジャンル名]',
     emoji: '[絵文字]',
     color: Color(0xFF[カラーコード]),
     description: '[説明文]',
   ),
   ```
3. `itemsByGenre` マップに新しいエントリを追加:
   ```dart
   '[snake_case_id]': [
     const Item(id: '[prefix]1', name: '[アイテム名]', genreId: '[snake_case_id]', popularityScore: [1-100]),
     // 最低10個以上のアイテムを追加
   ],
   ```

## 注意事項

- アイテムは最低10個必要
- popularityScore は知名度・人気度を1-100で表現
- idはジャンル内でユニークにする
