# サーバーセットアップガイド

このガイドでは、Firebase Cloud Messaging (FCM) を使用してiOSデバイスにPush通知を送信するNode.jsサーバーのセットアップ手順を説明します。

## 📋 前提条件

- Node.js 16.x以降がインストールされていること
- [Firebase セットアップガイド](./FIREBASE_SETUP.md) が完了していること
- Firebase Admin SDKの秘密鍵（`firebase-admin-key.json`）を取得していること

## 🚀 セットアップ手順

### 1. 依存関係のインストール

```bash
cd server
npm install
```

### 2. Firebase Admin SDKの秘密鍵を配置

1. Firebaseコンソールからダウンロードした秘密鍵ファイルを `firebase-admin-key.json` にリネーム
2. `server/` ディレクトリに配置
3. **重要**: このファイルは絶対にgitにコミットしないこと

### 3. 環境変数の設定（オプション）

`.env` ファイルを作成（オプション）：

```bash
FIREBASE_ADMIN_KEY_PATH=./firebase-admin-key.json
PORT=3000
```

## 📡 通知の送信方法

### 基本的な使い方

サーバーには以下のファイルが含まれています：

1. **send-notification.js** - 単一デバイスへの通知送信
2. **send-topic-notification.js** - トピック購読者への一斉送信
3. **send-custom-notification.js** - カスタムデータ付き通知

### 1. 単一デバイスへの通知送信

```bash
node send-notification.js <FCM_TOKEN>
```

例：
```bash
node send-notification.js "dXXXXXXXXX:APA91bGXXXXXXXXXXXXXXXXXXXXXXXX"
```

### 2. トピック購読者への一斉送信

```bash
node send-topic-notification.js <TOPIC_NAME>
```

例：
```bash
node send-topic-notification.js "news"
```

### 3. カスタムデータ付き通知

```bash
node send-custom-notification.js <FCM_TOKEN>
```

このスクリプトは、通知とともにカスタムデータを送信します。

## 📝 コードの説明

### send-notification.js

基本的な通知送信の例：

```javascript
const message = {
  notification: {
    title: 'タイトル',
    body: 'メッセージ本文',
  },
  token: fcmToken, // iOSアプリから取得したFCMトークン
};

const response = await admin.messaging().send(message);
```

### send-topic-notification.js

トピック購読者への送信：

```javascript
const message = {
  notification: {
    title: 'ニュース配信',
    body: '新しい記事が投稿されました',
  },
  topic: 'news',
};

const response = await admin.messaging().send(message);
```

### send-custom-notification.js

カスタムデータ付き通知：

```javascript
const message = {
  notification: {
    title: 'タイトル',
    body: 'メッセージ',
  },
  data: {
    screen: 'detail',
    id: '12345',
  },
  token: fcmToken,
};
```

## 🎨 通知のカスタマイズ

### APNs固有の設定

iOS向けに詳細な設定を行う場合：

```javascript
const message = {
  notification: {
    title: 'タイトル',
    body: 'メッセージ',
  },
  apns: {
    payload: {
      aps: {
        sound: 'default',
        badge: 1,
        'content-available': 1,
      },
    },
  },
  token: fcmToken,
};
```

### サウンドとバッジの設定

```javascript
apns: {
  payload: {
    aps: {
      sound: 'notification.wav', // カスタムサウンド
      badge: 5,                   // バッジの数
      category: 'MESSAGE',        // 通知カテゴリ
    },
  },
}
```

### サイレント通知（バックグラウンド更新）

```javascript
const message = {
  data: {
    type: 'background-update',
    content: 'データ更新',
  },
  apns: {
    payload: {
      aps: {
        'content-available': 1,
      },
    },
  },
  token: fcmToken,
};
```

## 🔒 セキュリティのベストプラクティス

### 1. 秘密鍵の管理

- `firebase-admin-key.json` をgitにコミットしない
- 環境変数を使用して秘密鍵のパスを管理
- 本番環境では暗号化されたストレージに保存

### 2. トークンの検証

送信前にFCMトークンの形式を検証：

```javascript
function isValidFCMToken(token) {
  return token && typeof token === 'string' && token.length > 0;
}
```

### 3. エラーハンドリング

```javascript
try {
  const response = await admin.messaging().send(message);
  console.log('通知送信成功:', response);
} catch (error) {
  if (error.code === 'messaging/invalid-registration-token') {
    console.error('無効なトークン');
    // トークンをデータベースから削除する処理
  } else if (error.code === 'messaging/registration-token-not-registered') {
    console.error('未登録のトークン');
  } else {
    console.error('送信エラー:', error);
  }
}
```

## 🧪 テスト

### 1. FCMトークンの取得

iOSアプリを実行して、画面に表示されるFCMトークンをコピーします。

### 2. テスト通知の送信

```bash
node send-notification.js "YOUR_FCM_TOKEN_HERE"
```

### 3. 確認

- アプリがフォアグラウンドの場合: アラートダイアログが表示される
- アプリがバックグラウンドの場合: 通知センターに通知が表示される

## 🛠️ トラブルシューティング

### 通知が届かない場合

1. **FCMトークンの確認**
   - トークンが正しくコピーされているか
   - トークンの有効期限が切れていないか

2. **Firebase設定の確認**
   - APNs認証キーが正しく設定されているか
   - Bundle Identifierが一致しているか

3. **デバイスの確認**
   - 実機で実行しているか（シミュレータでは受信できません）
   - 通知の許可が有効になっているか
   - インターネット接続があるか

4. **サーバーログの確認**
   - エラーメッセージを確認
   - レスポンスコードを確認

### よくあるエラー

**messaging/invalid-registration-token**
- トークンの形式が無効です
- 新しいトークンを取得してください

**messaging/registration-token-not-registered**
- トークンが登録されていないか、無効です
- アプリを再インストールして新しいトークンを取得してください

**messaging/invalid-apns-credentials**
- APNs認証キーの設定に問題があります
- Firebaseコンソールの設定を確認してください

## 📊 高度な機能

### バッチ送信

複数のデバイスに一度に送信：

```javascript
const message = {
  notification: {
    title: 'タイトル',
    body: 'メッセージ',
  },
  tokens: [token1, token2, token3], // 最大500個
};

const response = await admin.messaging().sendMulticast(message);
console.log(`成功: ${response.successCount}, 失敗: ${response.failureCount}`);
```

### 条件付き送信

複数のトピックを組み合わせた条件で送信：

```javascript
const message = {
  notification: {
    title: 'タイトル',
    body: 'メッセージ',
  },
  condition: "'news' in topics && 'premium' in topics",
};
```

## 📚 参考資料

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [FCM Server Reference](https://firebase.google.com/docs/cloud-messaging/send-message)
- [APNs Payload Key Reference](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)

## 🎯 次のステップ

- 通知のスケジューリング機能を実装
- データベースにトークンを保存
- ユーザーグループ管理機能を追加
- 通知の分析とトラッキングを実装
