# FCM通知送信サーバー

このディレクトリには、Firebase Cloud Messaging (FCM)を使用してiOSデバイスにPush通知を送信するためのNode.jsスクリプトが含まれています。

## 📋 前提条件

- Node.js 16.x以降
- Firebase Admin SDKの秘密鍵（`firebase-admin-key.json`）

## 🚀 セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. Firebase Admin SDKの秘密鍵を配置

Firebaseコンソールからダウンロードした秘密鍵ファイルを `firebase-admin-key.json` という名前でこのディレクトリに配置してください。

```
server/
├── firebase-admin-key.json  ← ここに配置
├── package.json
└── send-notification.js
```

**⚠️ 重要**: `firebase-admin-key.json` はgitにコミットしないでください。`.gitignore`に含まれています。

## 📡 使用方法

### 1. 基本的な通知送信

単一のデバイスに通知を送信：

```bash
node send-notification.js "FCM_TOKEN"
```

例：
```bash
node send-notification.js "dXXXXXXX:APA91bGXXXXXXXXXXXXXXXX"
```

### 2. トピック購読者への通知送信

特定のトピックを購読しているすべてのデバイスに通知を送信：

```bash
node send-topic-notification.js "TOPIC_NAME"
```

例：
```bash
node send-topic-notification.js "news"
node send-topic-notification.js "all-users"
```

### 3. カスタムデータ付き通知

カスタムデータペイロードを含む通知を送信：

```bash
node send-custom-notification.js "FCM_TOKEN"
```

このスクリプトは以下のカスタムデータを送信します：
- `type`: 通知のタイプ
- `screen`: 遷移先の画面
- `id`: コンテンツID
- `action`: 実行するアクション
- `metadata`: 追加のメタデータ（JSON形式）

### 4. バッチ送信

複数のデバイスに一度に通知を送信（最大500トークン）：

```bash
node send-batch-notification.js "TOKEN1" "TOKEN2" "TOKEN3"
```

## 📦 スクリプト一覧

| スクリプト | 説明 | 用途 |
|----------|------|------|
| `send-notification.js` | 単一デバイスへの基本的な通知送信 | 特定のユーザーへの通知 |
| `send-topic-notification.js` | トピック購読者への一斉送信 | 全ユーザーやグループへの通知 |
| `send-custom-notification.js` | カスタムデータ付き通知送信 | 画面遷移やアクション実行 |
| `send-batch-notification.js` | 複数デバイスへの一括送信 | セグメント配信 |

## 🔧 通知のカスタマイズ

### 通知の内容を変更

各スクリプトの `message` オブジェクトを編集してください：

```javascript
const message = {
  notification: {
    title: 'タイトルをここに',
    body: 'メッセージ本文をここに',
  },
  token: fcmToken,
};
```

### APNs固有の設定

iOS向けの詳細設定：

```javascript
apns: {
  payload: {
    aps: {
      sound: 'default',        // サウンド
      badge: 1,                // バッジ数
      'content-available': 1,  // バックグラウンド更新
      category: 'CATEGORY',    // 通知カテゴリ
    },
  },
}
```

### カスタムデータの追加

```javascript
data: {
  key1: 'value1',
  key2: 'value2',
  jsonData: JSON.stringify({ nested: 'object' }),
}
```

**注意**: `data` オブジェクトの値は全て文字列である必要があります。

## 🐛 トラブルシューティング

### エラー: firebase-admin-key.json が見つからない

```
❌ Error initializing Firebase Admin SDK:
   Make sure "firebase-admin-key.json" exists in the server directory
```

**解決方法**:
1. Firebaseコンソールから秘密鍵をダウンロード
2. ファイル名を `firebase-admin-key.json` に変更
3. `server/` ディレクトリに配置

### エラー: Invalid registration token

```
❌ Error: messaging/invalid-registration-token
```

**解決方法**:
- FCMトークンが正しいか確認
- トークンに余分なスペースや改行がないか確認
- iOSアプリから最新のトークンを取得

### エラー: Invalid APNs credentials

```
❌ Error: messaging/invalid-apns-credentials
```

**解決方法**:
- FirebaseコンソールでAPNs認証キーが正しく設定されているか確認
- Key IDとTeam IDが正しいか確認
- Bundle Identifierが一致しているか確認

### エラー: Registration token not registered

```
❌ Error: messaging/registration-token-not-registered
```

**解決方法**:
- アプリがアンインストールされた可能性があります
- 新しいトークンを取得してください

## 📚 参考資料

- [Firebase Admin SDK - Send Messages](https://firebase.google.com/docs/cloud-messaging/send-message)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [APNs Payload](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)

## 🔐 セキュリティ

- `firebase-admin-key.json` を公開リポジトリにコミットしない
- 本番環境では環境変数を使用して秘密鍵を管理
- トークンをデータベースで安全に管理
- 送信レートを制限してスパムを防止

## 💡 ヒント

### 環境変数を使用する場合

`.env` ファイルを作成：

```bash
FIREBASE_ADMIN_KEY_PATH=./firebase-admin-key.json
```

コードで読み込み：

```javascript
require('dotenv').config();
const keyPath = process.env.FIREBASE_ADMIN_KEY_PATH;
```

### トークンをファイルから読み込む

```javascript
const fs = require('fs');
const tokens = fs.readFileSync('tokens.txt', 'utf-8')
  .split('\n')
  .filter(token => token.trim().length > 0);
```

### 通知のスケジューリング

`node-cron` を使用：

```javascript
const cron = require('node-cron');

// 毎日午前9時に通知を送信
cron.schedule('0 9 * * *', () => {
  sendNotification(token);
});
```
