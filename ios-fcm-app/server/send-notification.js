#!/usr/bin/env node

/**
 * FCM通知送信スクリプト（単一デバイス向け）
 * 
 * 使い方:
 *   node send-notification.js <FCM_TOKEN>
 * 
 * 例:
 *   node send-notification.js "dXXXXXXX:APA91bGXXXXXXXXXXXXXXXX"
 */

const admin = require('firebase-admin');
const path = require('path');

// Firebase Admin SDKの初期化
const serviceAccountPath = path.join(__dirname, 'firebase-admin-key.json');

try {
  const serviceAccount = require(serviceAccountPath);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  console.log('✅ Firebase Admin SDK initialized successfully');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:');
  console.error('   Make sure "firebase-admin-key.json" exists in the server directory');
  console.error('   Error:', error.message);
  process.exit(1);
}

/**
 * FCM通知を送信する
 */
async function sendNotification(fcmToken) {
  // 通知メッセージの作成
  const message = {
    notification: {
      title: '📱 テスト通知',
      body: 'FCMからの通知が正常に送信されました！',
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

  try {
    // 通知を送信
    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent successfully!');
    console.log('📝 Message ID:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:');
    
    // エラーの詳細を表示
    if (error.code === 'messaging/invalid-registration-token') {
      console.error('   Invalid FCM token. Please check the token and try again.');
    } else if (error.code === 'messaging/registration-token-not-registered') {
      console.error('   FCM token is not registered. The app may have been uninstalled.');
    } else if (error.code === 'messaging/invalid-apns-credentials') {
      console.error('   Invalid APNs credentials. Check Firebase Console settings.');
    } else {
      console.error('   Error code:', error.code);
      console.error('   Error message:', error.message);
    }
    
    throw error;
  }
}

// メイン処理
(async () => {
  // コマンドライン引数からFCMトークンを取得
  const fcmToken = process.argv[2];

  if (!fcmToken) {
    console.error('❌ Error: FCM token is required');
    console.error('');
    console.error('Usage:');
    console.error('  node send-notification.js <FCM_TOKEN>');
    console.error('');
    console.error('Example:');
    console.error('  node send-notification.js "dXXXXXXX:APA91bGXXXXXXXXXXXXXXXX"');
    process.exit(1);
  }

  console.log('📤 Sending notification...');
  console.log('🎯 Target token:', fcmToken.substring(0, 20) + '...');
  console.log('');

  try {
    await sendNotification(fcmToken);
    console.log('');
    console.log('🎉 Notification sent successfully!');
    console.log('   Check your iOS device to see the notification.');
    process.exit(0);
  } catch (error) {
    console.log('');
    console.error('💥 Failed to send notification');
    process.exit(1);
  }
})();
