#!/usr/bin/env node

/**
 * FCM通知送信スクリプト（バッチ送信）
 * 
 * 使い方:
 *   node send-batch-notification.js <TOKEN1> <TOKEN2> <TOKEN3> ...
 * 
 * 例:
 *   node send-batch-notification.js "token1" "token2" "token3"
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
 * 複数のデバイスにFCM通知を一括送信する
 */
async function sendBatchNotification(tokens) {
  // バッチ通知メッセージの作成
  const message = {
    notification: {
      title: '📢 一斉通知',
      body: '複数のデバイスに一度に送信されました',
    },
    data: {
      type: 'batch',
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
    tokens: tokens, // 複数のトークンを指定
  };

  try {
    // マルチキャスト送信（最大500トークンまで）
    const response = await admin.messaging().sendEachForMulticast(message);
    
    console.log('✅ Batch notification sent!');
    console.log('');
    console.log('📊 Results:');
    console.log('   Success count:', response.successCount);
    console.log('   Failure count:', response.failureCount);
    console.log('');
    
    // 失敗したトークンの詳細を表示
    if (response.failureCount > 0) {
      console.log('❌ Failed tokens:');
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.log(`   [${idx}] ${tokens[idx].substring(0, 20)}...`);
          console.log(`       Error: ${resp.error.code} - ${resp.error.message}`);
        }
      });
      console.log('');
    }
    
    return response;
  } catch (error) {
    console.error('❌ Error sending batch notification:');
    console.error('   Error code:', error.code);
    console.error('   Error message:', error.message);
    throw error;
  }
}

/**
 * トークンの検証
 */
function validateTokens(tokens) {
  if (!Array.isArray(tokens) || tokens.length === 0) {
    throw new Error('At least one token is required');
  }
  
  if (tokens.length > 500) {
    throw new Error('Maximum 500 tokens allowed per batch');
  }
  
  // 空のトークンを除外
  const validTokens = tokens.filter(token => token && token.trim().length > 0);
  
  if (validTokens.length === 0) {
    throw new Error('No valid tokens provided');
  }
  
  return validTokens;
}

// メイン処理
(async () => {
  // コマンドライン引数からFCMトークンのリストを取得
  const tokens = process.argv.slice(2);

  if (tokens.length === 0) {
    console.error('❌ Error: At least one FCM token is required');
    console.error('');
    console.error('Usage:');
    console.error('  node send-batch-notification.js <TOKEN1> <TOKEN2> <TOKEN3> ...');
    console.error('');
    console.error('Example:');
    console.error('  node send-batch-notification.js "token1" "token2" "token3"');
    console.error('');
    console.error('📝 Note:');
    console.error('   - Maximum 500 tokens per batch');
    console.error('   - Use quotes for tokens containing special characters');
    process.exit(1);
  }

  try {
    // トークンの検証
    const validTokens = validateTokens(tokens);
    
    console.log('📤 Sending batch notification...');
    console.log('🎯 Target tokens:', validTokens.length);
    console.log('');
    
    // トークンのプレビュー（最初の3つ）
    console.log('Preview:');
    validTokens.slice(0, 3).forEach((token, idx) => {
      console.log(`   [${idx + 1}] ${token.substring(0, 20)}...`);
    });
    if (validTokens.length > 3) {
      console.log(`   ... and ${validTokens.length - 3} more`);
    }
    console.log('');

    // バッチ送信
    await sendBatchNotification(validTokens);
    
    console.log('🎉 Batch notification completed!');
    console.log('   Check the devices to see the notifications.');
    process.exit(0);
  } catch (error) {
    console.log('');
    console.error('💥 Failed to send batch notification');
    console.error('   Error:', error.message);
    process.exit(1);
  }
})();
