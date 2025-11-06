#!/usr/bin/env node

/**
 * FCM通知送信スクリプト（カスタムデータ付き）
 * 
 * 使い方:
 *   node send-custom-notification.js <FCM_TOKEN>
 * 
 * 例:
 *   node send-custom-notification.js "dXXXXXXX:APA91bGXXXXXXXXXXXXXXXX"
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
 * カスタムデータ付きFCM通知を送信する
 */
async function sendCustomNotification(fcmToken) {
  // 現在の時刻
  const timestamp = new Date().toISOString();
  
  // カスタムデータを含む通知メッセージの作成
  const message = {
    notification: {
      title: '🎁 カスタムデータ付き通知',
      body: 'この通知にはカスタムデータが含まれています',
    },
    data: {
      // カスタムデータ（全て文字列である必要がある）
      type: 'custom',
      screen: 'detail',
      id: '12345',
      timestamp: timestamp,
      action: 'open_screen',
      // JSONデータを送信する場合は文字列化
      metadata: JSON.stringify({
        category: 'news',
        priority: 'high',
        source: 'api',
      }),
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          'content-available': 1,
          category: 'CUSTOM_CATEGORY',
        },
        // APNs固有のカスタムデータ
        customData: {
          deeplink: 'myapp://detail/12345',
        },
      },
    },
    token: fcmToken,
  };

  try {
    // 通知を送信
    const response = await admin.messaging().send(message);
    console.log('✅ Custom notification sent successfully!');
    console.log('📝 Message ID:', response);
    console.log('');
    console.log('📦 Sent custom data:');
    console.log('   - type:', message.data.type);
    console.log('   - screen:', message.data.screen);
    console.log('   - id:', message.data.id);
    console.log('   - timestamp:', message.data.timestamp);
    console.log('   - action:', message.data.action);
    console.log('   - metadata:', message.data.metadata);
    return response;
  } catch (error) {
    console.error('❌ Error sending custom notification:');
    
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

/**
 * サイレント通知（バックグラウンド更新）を送信する
 */
async function sendSilentNotification(fcmToken) {
  const message = {
    data: {
      type: 'silent',
      action: 'background_update',
      content: JSON.stringify({
        updateType: 'data_sync',
        lastSync: new Date().toISOString(),
      }),
    },
    apns: {
      headers: {
        'apns-priority': '5', // 低優先度
      },
      payload: {
        aps: {
          'content-available': 1,
          // サイレント通知のためalertやsoundは含めない
        },
      },
    },
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ Silent notification sent successfully!');
    console.log('📝 Message ID:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending silent notification:', error.message);
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
    console.error('  node send-custom-notification.js <FCM_TOKEN>');
    console.error('');
    console.error('Example:');
    console.error('  node send-custom-notification.js "dXXXXXXX:APA91bGXXXXXXXXXXXXXXXX"');
    console.error('');
    console.error('This script sends a notification with custom data payload.');
    console.error('The app can use this data to navigate to specific screens or perform actions.');
    process.exit(1);
  }

  console.log('📤 Sending custom notification...');
  console.log('🎯 Target token:', fcmToken.substring(0, 20) + '...');
  console.log('');

  try {
    await sendCustomNotification(fcmToken);
    console.log('');
    console.log('🎉 Custom notification sent successfully!');
    console.log('   Check your iOS device and the app logs to see the custom data.');
    console.log('');
    console.log('💡 Tip:');
    console.log('   In the iOS app, you can access custom data via userInfo dictionary.');
    console.log('   Use this data to navigate to specific screens or trigger actions.');
    process.exit(0);
  } catch (error) {
    console.log('');
    console.error('💥 Failed to send custom notification');
    process.exit(1);
  }
})();
