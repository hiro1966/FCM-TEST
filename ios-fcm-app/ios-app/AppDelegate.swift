//
//  AppDelegate.swift
//  iOSFCMApp
//
//  FCM (Firebase Cloud Messaging) を使用したPush通知の実装
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Firebase の初期化
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        
        // FCM デリゲートの設定
        Messaging.messaging().delegate = self
        
        // 通知デリゲートの設定
        UNUserNotificationCenter.current().delegate = self
        
        // 通知の許可をリクエスト
        requestNotificationAuthorization()
        
        // リモート通知の登録
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - 通知許可のリクエスト
    
    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("✅ Notification authorization granted")
            } else {
                print("⚠️ Notification authorization denied")
            }
        }
    }
    
    // MARK: - APNs Token Registration
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APNs トークンを取得
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNs device token: \(token)")
        
        // FCM に APNs トークンを設定
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - UISceneSession Lifecycle (iOS 13+)
    
    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    // FCM トークンが更新された時に呼ばれる
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else {
            print("⚠️ FCM token is nil")
            return
        }
        
        print("🔑 FCM registration token: \(token)")
        
        // トークンをサーバーに送信する処理をここに実装
        // 例: sendTokenToServer(token)
        
        // UserDefaults に保存（オプション）
        UserDefaults.standard.set(token, forKey: "FCMToken")
        
        // 通知を送信してUIを更新
        NotificationCenter.default.post(
            name: NSNotification.Name("FCMTokenUpdated"),
            object: nil,
            userInfo: ["token": token]
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // フォアグラウンドで通知を受信した時
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        print("📬 Notification received in foreground")
        print("📝 User Info: \(userInfo)")
        
        // 通知を表示（iOS 14+ では .banner、iOS 13 以前は .alert）
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // 通知をタップした時
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        print("👆 Notification tapped")
        print("📝 User Info: \(userInfo)")
        
        // カスタムデータがある場合の処理
        if let screen = userInfo["screen"] as? String {
            print("🔀 Navigate to screen: \(screen)")
            // 画面遷移の処理をここに実装
        }
        
        // 通知を処理したことを通知
        NotificationCenter.default.post(
            name: NSNotification.Name("NotificationTapped"),
            object: nil,
            userInfo: userInfo
        )
        
        completionHandler()
    }
}
