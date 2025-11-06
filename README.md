# iOS FCM Push通知アプリ

このプロジェクトは、Firebase Cloud Messaging (FCM)を使用してiPhoneにPush通知を送信するための完全なセットアップを提供します。

## 📁 プロジェクト構造

```
ios-fcm-app/
├── ios-app/           # iOSアプリケーション（Swift）
├── server/            # FCM通知送信サーバー（Node.js）
└── docs/              # ドキュメント
```

## 🚀 クイックスタート

### 必要な環境

- **iOS開発**:
  - macOS（Xcode 14.0以降）
  - CocoaPods
  - Apple Developer Account（Push通知用）
  - Firebase プロジェクト

- **サーバー**:
  - Node.js 16.x以降
  - Firebase Admin SDK

### セットアップ手順

詳細なセットアップ手順は以下のドキュメントを参照してください：

1. [Firebase セットアップガイド](./docs/FIREBASE_SETUP.md)
2. [iOS アプリセットアップガイド](./docs/IOS_SETUP.md)
3. [サーバーセットアップガイド](./docs/SERVER_SETUP.md)

## 📱 iOSアプリの主な機能

- FCMトークンの自動取得と管理
- フォアグラウンド通知の受信
- バックグラウンド通知の受信
- 通知タップ時のハンドリング
- APNs (Apple Push Notification service) との統合

## 🖥️ サーバーの主な機能

- 特定のデバイストークンへの通知送信
- トピック購読による一斉配信
- カスタムデータペイロードのサポート
- 通知のスケジューリング

## 🔐 セキュリティ上の注意

- `GoogleService-Info.plist` ファイルはgitにコミットしないこと
- Firebase Admin SDK の秘密鍵は安全に管理すること
- `.gitignore` ファイルを正しく設定すること

## 📚 参考資料

- [Firebase Cloud Messaging公式ドキュメント](https://firebase.google.com/docs/cloud-messaging)
- [iOS向けFCM実装ガイド](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## ⚙️ トラブルシューティング

よくある問題と解決方法については、[トラブルシューティングガイド](./docs/TROUBLESHOOTING.md)を参照してください。

## 📄 ライセンス

MIT License
