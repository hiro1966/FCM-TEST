# トラブルシューティングガイド

このドキュメントでは、iOS FCM Push通知の実装でよくある問題と解決方法をまとめています。

## 📱 iOSアプリの問題

### 問題1: FCMトークンが取得できない

**症状**:
- アプリを起動してもFCMトークンが表示されない
- コンソールに「FCM registration token」が出力されない

**解決方法**:

1. **GoogleService-Info.plistの確認**
   ```
   ✓ ファイルがXcodeプロジェクトに追加されているか
   ✓ ターゲットに含まれているか
   ✓ Bundle Identifierが一致しているか
   ```

2. **実機で実行**
   - シミュレータではAPNsトークンが取得できません
   - 必ず実機で動作確認してください

3. **Capabilitiesの確認**
   ```
   ✓ Push Notifications が追加されているか
   ✓ Background Modes → Remote notifications が有効か
   ```

4. **Firebase初期化の確認**
   ```swift
   // AppDelegate.swiftで以下が実行されているか確認
   FirebaseApp.configure()
   ```

5. **ネットワーク接続**
   - インターネット接続があるか確認
   - VPNを使用している場合は一時的に無効にして試す

### 問題2: APNsデバイストークンが取得できない

**症状**:
- `didRegisterForRemoteNotificationsWithDeviceToken` が呼ばれない
- 「APNs device token」がログに出力されない

**解決方法**:

1. **Apple Developer設定の確認**
   - App IDが正しく登録されているか
   - Bundle Identifierが一致しているか

2. **プロビジョニングプロファイルの確認**
   - Push Notifications が有効なプロファイルを使用しているか
   - Xcodeで自動署名を使用している場合は、一度手動署名に切り替えてみる

3. **デバイスの確認**
   - デバイスがApple Developer Accountに登録されているか
   - デバイスの「設定」→「一般」→「日付と時刻」が正しいか

### 問題3: 通知の許可が表示されない

**症状**:
- アプリ起動時に通知許可のダイアログが表示されない

**解決方法**:

1. **アプリを削除して再インストール**
   ```
   一度許可を拒否すると、再度表示されません。
   アプリを削除して再インストールしてください。
   ```

2. **設定から手動で許可**
   ```
   設定 → 通知 → アプリ名 → 通知を許可
   ```

3. **コードの確認**
   ```swift
   UNUserNotificationCenter.current().requestAuthorization(
       options: [.alert, .badge, .sound]
   )
   ```

### 問題4: フォアグラウンドで通知が表示されない

**症状**:
- アプリがアクティブな状態で通知が届かない
- バックグラウンドでは正常に動作する

**解決方法**:

1. **UNUserNotificationCenterDelegateの実装**
   ```swift
   func userNotificationCenter(
       _ center: UNUserNotificationCenter,
       willPresent notification: UNNotification,
       withCompletionHandler completionHandler: 
       @escaping (UNNotificationPresentationOptions) -> Void
   ) {
       completionHandler([.banner, .sound, .badge])
   }
   ```

2. **iOS 14以降の場合**
   ```swift
   // .banner を使用（.alertは非推奨）
   completionHandler([.banner, .sound, .badge])
   ```

### 問題5: ビルドエラー

**症状**:
- `'FirebaseCore/FirebaseCore.h' file not found`
- `Undefined symbol: _OBJC_CLASS_$_FIRApp`

**解決方法**:

1. **Podの再インストール**
   ```bash
   cd ios-app
   pod deintegrate
   pod install
   ```

2. **Xcodeのクリーン**
   ```
   Product → Clean Build Folder (Shift + Cmd + K)
   ```

3. **Derived Dataの削除**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

4. **Workspaceを使用**
   ```
   .xcodeprojではなく、.xcworkspaceを開く
   ```

## 🖥️ サーバー側の問題

### 問題1: 通知が送信されない

**症状**:
- スクリプトを実行してもエラーが出る
- 通知がデバイスに届かない

**解決方法**:

1. **Firebase Admin SDKの初期化確認**
   ```javascript
   // firebase-admin-key.jsonのパスが正しいか確認
   const serviceAccount = require('./firebase-admin-key.json');
   ```

2. **FCMトークンの確認**
   ```javascript
   // トークンが正しい形式か確認
   console.log('Token length:', token.length);
   console.log('Token:', token);
   ```

3. **エラーログの確認**
   ```javascript
   try {
     const response = await admin.messaging().send(message);
     console.log('Success:', response);
   } catch (error) {
     console.error('Error code:', error.code);
     console.error('Error message:', error.message);
   }
   ```

### 問題2: Invalid registration token エラー

**症状**:
```
Error: messaging/invalid-registration-token
```

**解決方法**:

1. **トークンの再取得**
   - iOSアプリで新しいトークンを取得
   - コピー時にスペースや改行が入っていないか確認

2. **トークンの形式確認**
   ```javascript
   // FCMトークンは通常150-200文字程度
   // コロン(:)を含む文字列
   console.log('Token format check:', token.includes(':'));
   ```

3. **環境の確認**
   - 開発環境と本番環境でトークンが異なる
   - 正しい環境のトークンを使用しているか確認

### 問題3: Invalid APNs credentials エラー

**症状**:
```
Error: messaging/invalid-apns-credentials
```

**解決方法**:

1. **FirebaseコンソールでAPNs設定確認**
   - APNs認証キー（.p8ファイル）が正しくアップロードされているか
   - Key IDが正しいか
   - Team IDが正しいか

2. **Bundle Identifierの確認**
   - FirebaseコンソールのiOSアプリ設定
   - Xcodeプロジェクトの設定
   - APNs証明書/キーの対象App ID

3. **APNs認証キーの再作成**
   - Apple Developer Consoleで新しいキーを作成
   - Firebaseに再アップロード

### 問題4: Registration token not registered エラー

**症状**:
```
Error: messaging/registration-token-not-registered
```

**解決方法**:

1. **トークンの有効性確認**
   - アプリがアンインストールされた可能性
   - トークンの有効期限が切れた可能性

2. **トークンの更新**
   ```swift
   // iOS側でトークン更新を検知
   func messaging(_ messaging: Messaging, 
                  didReceiveRegistrationToken fcmToken: String?) {
       print("Token updated:", fcmToken)
       // サーバーに新しいトークンを送信
   }
   ```

3. **データベースのクリーンアップ**
   - 無効なトークンをデータベースから削除
   - エラー発生時にトークンを無効化する処理を追加

## 🔍 デバッグのヒント

### iOSアプリのデバッグ

1. **詳細ログの有効化**
   ```swift
   // AppDelegate.swift
   #if DEBUG
   FirebaseConfiguration.shared.setLoggerLevel(.debug)
   #endif
   ```

2. **通知ペイロードの確認**
   ```swift
   func userNotificationCenter(
       _ center: UNUserNotificationCenter,
       willPresent notification: UNNotification
   ) {
       print("Notification payload:", notification.request.content.userInfo)
   }
   ```

3. **APNsトークンのフォーマット確認**
   ```swift
   func application(
       _ application: UIApplication,
       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
   ) {
       let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
       print("APNs token:", token)
   }
   ```

### サーバー側のデバッグ

1. **送信メッセージの内容確認**
   ```javascript
   console.log('Sending message:', JSON.stringify(message, null, 2));
   ```

2. **レスポンスの詳細確認**
   ```javascript
   const response = await admin.messaging().send(message);
   console.log('Message ID:', response);
   console.log('Success count:', response.successCount);
   ```

3. **エラーの詳細情報**
   ```javascript
   catch (error) {
       console.error('Error details:', {
           code: error.code,
           message: error.message,
           stack: error.stack
       });
   }
   ```

## 📋 チェックリスト

問題が発生した場合、以下の項目を順番に確認してください：

### iOS側
- [ ] 実機で実行している
- [ ] GoogleService-Info.plistが追加されている
- [ ] Bundle Identifierが一致している
- [ ] Push Notifications Capabilityが有効
- [ ] Background Modes（Remote notifications）が有効
- [ ] 通知の許可が有効
- [ ] インターネット接続がある
- [ ] Firebaseが正しく初期化されている

### Firebase側
- [ ] iOSアプリが登録されている
- [ ] APNs認証キー（.p8）がアップロードされている
- [ ] Key IDが正しい
- [ ] Team IDが正しい
- [ ] Bundle Identifierが一致している

### サーバー側
- [ ] firebase-admin-key.jsonが配置されている
- [ ] Node.jsのバージョンが16.x以降
- [ ] 必要なnpmパッケージがインストールされている
- [ ] FCMトークンが正しい
- [ ] エラーハンドリングが実装されている

## 📚 参考資料

- [Firebase iOS Troubleshooting](https://firebase.google.com/docs/cloud-messaging/ios/client#troubleshooting)
- [APNs Troubleshooting](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns#3394239)
- [FCM Error Codes](https://firebase.google.com/docs/reference/fcm/rest/v1/ErrorCode)

## 💬 サポート

問題が解決しない場合：

1. Firebase サポートフォーラムで質問
2. Stack Overflow で検索
3. GitHubのIssueを作成

エラーログや設定内容を詳しく記載すると、解決が早くなります。
