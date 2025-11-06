# Firebase セットアップガイド

このガイドでは、FCM（Firebase Cloud Messaging）を使用するために必要なFirebaseプロジェクトのセットアップ手順を説明します。

## 📋 前提条件

- Googleアカウント
- Apple Developer Account（APNs認証キー取得用）

## 🔥 Firebaseプロジェクトの作成

### 1. Firebaseコンソールでプロジェクトを作成

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名を入力（例: `my-ios-fcm-app`）
4. Google Analyticsの設定（オプション）
5. プロジェクトを作成

### 2. iOSアプリをFirebaseに追加

1. Firebaseコンソールのプロジェクト概要ページで「iOS」アイコンをクリック
2. 以下の情報を入力：
   - **iOSバンドルID**: `com.yourcompany.iosfcmapp`（Xcodeプロジェクトと同じものを使用）
   - **アプリのニックネーム**: 任意（例: `iOS FCM App`）
   - **App Store ID**: オプション

3. 「アプリを登録」をクリック

### 3. GoogleService-Info.plist をダウンロード

1. `GoogleService-Info.plist` ファイルをダウンロード
2. このファイルをiOSプロジェクトのルートディレクトリに配置
3. **重要**: このファイルはgitにコミットしないこと（`.gitignore`に追加）

### 4. Firebase SDKを追加

CocoaPodsを使用する場合（推奨）:

```ruby
# Podfile
platform :ios, '13.0'
use_frameworks!

target 'YourAppName' do
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end
```

インストール:
```bash
cd ios-app
pod install
```

## 🍎 APNs認証キーの設定

FCMがAPNs（Apple Push Notification service）経由で通知を送信するために、APNs認証キーが必要です。

### 1. APNs認証キーの作成

1. [Apple Developer Console](https://developer.apple.com/account/) にログイン
2. 「Certificates, Identifiers & Profiles」に移動
3. 左メニューから「Keys」を選択
4. 「+」ボタンをクリックして新しいキーを作成
5. キー名を入力（例: `FCM APNs Key`）
6. 「Apple Push Notifications service (APNs)」にチェック
7. 「Continue」→「Register」をクリック
8. **重要**: `.p8` ファイルをダウンロード（再ダウンロード不可）
9. **Key ID** をメモ

### 2. Team IDの確認

1. Apple Developer Consoleの「Membership」ページに移動
2. **Team ID** をメモ

### 3. Firebaseコンソールに APNs キーを登録

1. Firebaseコンソールのプロジェクト設定に移動
2. 「Cloud Messaging」タブを選択
3. 「APNs認証キー」セクションで「アップロード」をクリック
4. 以下を入力：
   - APNs認証キー（.p8ファイル）
   - Key ID
   - Team ID
5. 「アップロード」をクリック

## 🔑 Firebase Admin SDK の設定（サーバー側）

サーバーからFCM通知を送信するために、Firebase Admin SDKの秘密鍵が必要です。

### 1. サービスアカウントキーの生成

1. Firebaseコンソールのプロジェクト設定に移動
2. 「サービスアカウント」タブを選択
3. 「新しい秘密鍵の生成」をクリック
4. JSONファイルがダウンロードされます
5. ファイル名を `firebase-admin-key.json` に変更
6. このファイルを `server/` ディレクトリに配置
7. **重要**: このファイルはgitにコミットしないこと

### 2. .gitignore の設定

```gitignore
# Firebase設定ファイル
GoogleService-Info.plist
firebase-admin-key.json

# CocoaPods
Pods/
*.xcworkspace
Podfile.lock

# Xcode
*.xcuserdata
*.xcuserdatad
DerivedData/

# Node.js
node_modules/
.env
```

## ✅ セットアップの確認

以下が完了していることを確認してください：

- ✅ Firebaseプロジェクトが作成されている
- ✅ iOSアプリがFirebaseに登録されている
- ✅ `GoogleService-Info.plist` がダウンロードされている
- ✅ APNs認証キーがFirebaseに登録されている
- ✅ Firebase Admin SDKの秘密鍵がダウンロードされている
- ✅ `.gitignore` が正しく設定されている

## 🎯 次のステップ

Firebase の設定が完了したら、以下のガイドに進んでください：

1. [iOS アプリセットアップガイド](./IOS_SETUP.md) - iOSアプリの実装
2. [サーバーセットアップガイド](./SERVER_SETUP.md) - 通知送信サーバーの実装

## 📚 参考資料

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [FCM APNs Configuration](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- [Firebase Admin SDK Setup](https://firebase.google.com/docs/admin/setup)
