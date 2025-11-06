# iOS アプリセットアップガイド

このガイドでは、FCM（Firebase Cloud Messaging）を統合したiOSアプリの実装手順を説明します。

## 📋 前提条件

- macOS（Xcode 14.0以降がインストールされていること）
- CocoaPods がインストールされていること
- [Firebase セットアップガイド](./FIREBASE_SETUP.md) が完了していること

## 🚀 プロジェクトのセットアップ

### 1. Xcodeプロジェクトの作成

1. Xcodeを起動
2. 「Create a new Xcode project」を選択
3. 「iOS」→「App」を選択
4. プロジェクト設定：
   - **Product Name**: `iOSFCMApp`
   - **Bundle Identifier**: `com.yourcompany.iosfcmapp`（Firebaseで登録したものと同じ）
   - **Interface**: UIKit（または SwiftUI）
   - **Language**: Swift
5. プロジェクトを保存（`ios-fcm-app/ios-app/` ディレクトリに）

### 2. CocoaPodsの設定

プロジェクトディレクトリで以下を実行：

```bash
cd ios-app
pod init
```

`Podfile` を以下のように編集：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'iOSFCMApp' do
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end
```

依存関係をインストール：

```bash
pod install
```

**重要**: 以降は `iOSFCMApp.xcworkspace` を開いてください（`.xcodeproj` ではない）

### 3. GoogleService-Info.plist の追加

1. Firebaseからダウンロードした `GoogleService-Info.plist` をXcodeプロジェクトにドラッグ＆ドロップ
2. 「Copy items if needed」にチェック
3. ターゲットに追加されていることを確認

### 4. Push通知の Capability を追加

1. Xcodeでプロジェクトを選択
2. 「Signing & Capabilities」タブを選択
3. 「+ Capability」をクリック
4. 「Push Notifications」を追加
5. 「Background Modes」を追加
6. 「Remote notifications」にチェック

## 📱 コードの実装

このリポジトリには、すでに実装済みのコードが含まれています：

- `AppDelegate.swift` - Firebaseの初期化とFCMの設定
- `ViewController.swift` - FCMトークンの表示と通知処理
- `Info.plist` - 必要な設定

### コードの配置

以下のファイルを `ios-app/iOSFCMApp/` ディレクトリに配置してください：

1. `AppDelegate.swift`
2. `ViewController.swift`
3. `Info.plist` の設定を更新

## 🔧 主な実装内容

### AppDelegate.swift

- Firebaseの初期化
- FCMデリゲートの設定
- APNsデバイストークンの登録
- FCMトークンの取得と更新
- リモート通知の処理

### ViewController.swift

- FCMトークンのUI表示
- トークンのコピー機能
- 通知受信時のアラート表示

## 🧪 動作確認

### 1. アプリのビルドと実行

1. 実機のiOSデバイスを接続（シミュレータではPush通知は受信できません）
2. Xcodeで実機を選択
3. 「Product」→「Run」でアプリを起動

### 2. FCMトークンの確認

1. アプリが起動すると、FCMトークンが画面に表示されます
2. トークンをコピー（「Copy Token」ボタンをタップ）
3. このトークンを使ってサーバーから通知を送信できます

### 3. Push通知の権限を許可

アプリ起動時に通知の許可を求められるので、「許可」を選択してください。

## 🔍 デバッグ

### Xcodeコンソールでログを確認

以下のようなログが出力されます：

```
Firebase configured successfully
APNs device token: <your-apns-token>
FCM registration token: <your-fcm-token>
```

### トークンが取得できない場合

1. `GoogleService-Info.plist` が正しく追加されているか確認
2. Bundle Identifierが一致しているか確認
3. Push Notifications Capabilityが追加されているか確認
4. 実機で実行しているか確認（シミュレータでは動作しません）
5. FirebaseコンソールでAPNs認証キーが正しく設定されているか確認

## 📝 Info.plist の設定

以下の設定が必要です：

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 🎯 次のステップ

iOSアプリの実装が完了したら、サーバー側の実装に進んでください：

[サーバーセットアップガイド](./SERVER_SETUP.md)

## 📚 参考資料

- [Firebase iOS Client Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications)
- [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter)
