#!/usr/bin/env node

/**
 * FCM通知送信スクリプト（トピック購読者向け）
 * 
 * 使い方:
 *   node send-topic-notification.js <TOPIC_NAME>
 * 
 * 例:
 *   node send-topic-notification.js "news"
 *   node send-topic-notification.js "all-users"
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
 * トピック購読者にFCM通知を送信する
 */
async function sendTopicNotification(topic) {
  // 通知メッセージの作成
  const message = {
    notification: {
      title: `📢 ${topic} からのお知らせ`,
      body: 'トピック購読者への一斉通知です',
    },
    data: {
      topic: topic,
      timestamp: new Date().toISOString(),
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
    topic: topic,
  };

  try {
    // 通知を送信
    const response = await admin.messaging().send(message);
    console.log('✅ Topic notification sent successfully!');
    console.log('📝 Message ID:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending topic notification:');
    
    if (error.code === 'messaging/invalid-argument') {
      console.error('   Invalid topic name. Topic must match [a-zA-Z0-9-_.~%]+');
    } else {
      console.error('   Error code:', error.code);
      console.error('   Error message:', error.message);
    }
    
    throw error;
  }
}

/**
 * デバイスをトピックに登録する
 */
async function subscribeToTopic(tokens, topic) {
  try {
    const response = await admin.messaging().subscribeToTopic(tokens, topic);
    console.log('✅ Successfully subscribed to topic:');
    console.log('   Success count:', response.successCount);
    console.log('   Failure count:', response.failureCount);
    return response;
  } catch (error) {
    console.error('❌ Error subscribing to topic:', error.message);
    throw error;
  }
}

// メイン処理
(async () => {
  // コマンドライン引数からトピック名を取得
  const topic = process.argv[2];

  if (!topic) {
    console.error('❌ Error: Topic name is required');
    console.error('');
    console.error('Usage:');
    console.error('  node send-topic-notification.js <TOPIC_NAME>');
    console.error('');
    console.error('Example:');
    console.error('  node send-topic-notification.js "news"');
    console.error('  node send-topic-notification.js "all-users"');
    console.error('');
    console.error('📝 Note:');
    console.error('   Devices must be subscribed to the topic to receive notifications.');
    console.error('   You can subscribe devices using the iOS app or via API.');
    process.exit(1);
  }

  // トピック名の検証
  const topicRegex = /^[a-zA-Z0-9-_.~%]+$/;
  if (!topicRegex.test(topic)) {
    console.error('❌ Error: Invalid topic name');
    console.error('   Topic must match pattern: [a-zA-Z0-9-_.~%]+');
    process.exit(1);
  }

  console.log('📤 Sending notification to topic...');
  console.log('🎯 Target topic:', topic);
  console.log('');

  try {
    await sendTopicNotification(topic);
    console.log('');
    console.log('🎉 Topic notification sent successfully!');
    console.log('   All devices subscribed to "' + topic + '" will receive the notification.');
    process.exit(0);
  } catch (error) {
    console.log('');
    console.error('💥 Failed to send topic notification');
    process.exit(1);
  }
})();
