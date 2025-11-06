//
//  ViewController.swift
//  iOSFCMApp
//
//  FCMトークンを表示し、通知を受信するメイン画面
//

import UIKit
import FirebaseMessaging

class ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "📱 iOS FCM Push通知"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "FCMトークンを取得中..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tokenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "FCM Token:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tokenTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.textColor = .label
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📋 Copy Token", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = """
        📝 使い方:
        
        1. 上記のFCMトークンをコピー
        2. サーバー側でこのトークンを使用
        3. 通知を送信してテスト
        
        ⚠️ 注意:
        • 実機でのみ動作します
        • 通知の許可が必要です
        • インターネット接続が必要です
        """
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lastNotificationLabel: UILabel = {
        let label = UILabel()
        label.text = "最後に受信した通知:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.textColor = .label
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.text = "通知を受信するとここに表示されます"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupNotificationObservers()
        loadFCMToken()
        
        // ボタンのアクション
        copyButton.addTarget(self, action: #selector(copyTokenTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(tokenTitleLabel)
        contentView.addSubview(tokenTextView)
        contentView.addSubview(copyButton)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(lastNotificationLabel)
        contentView.addSubview(notificationTextView)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Token Title
            tokenTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
            tokenTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tokenTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Token TextView
            tokenTextView.topAnchor.constraint(equalTo: tokenTitleLabel.bottomAnchor, constant: 8),
            tokenTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tokenTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tokenTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Copy Button
            copyButton.topAnchor.constraint(equalTo: tokenTextView.bottomAnchor, constant: 12),
            copyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 200),
            copyButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: copyButton.bottomAnchor, constant: 24),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Last Notification Label
            lastNotificationLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 24),
            lastNotificationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lastNotificationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Notification TextView
            notificationTextView.topAnchor.constraint(equalTo: lastNotificationLabel.bottomAnchor, constant: 8),
            notificationTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notificationTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notificationTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            notificationTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Notification Observers
    
    private func setupNotificationObservers() {
        // FCMトークン更新の通知を受け取る
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fcmTokenUpdated(_:)),
            name: NSNotification.Name("FCMTokenUpdated"),
            object: nil
        )
        
        // 通知タップの通知を受け取る
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationTapped(_:)),
            name: NSNotification.Name("NotificationTapped"),
            object: nil
        )
    }
    
    // MARK: - FCM Token
    
    private func loadFCMToken() {
        // 保存されているトークンを読み込む
        if let savedToken = UserDefaults.standard.string(forKey: "FCMToken") {
            updateTokenDisplay(savedToken)
        }
        
        // 最新のトークンを取得
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching FCM token: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.statusLabel.text = "❌ トークン取得エラー"
                    self.statusLabel.textColor = .systemRed
                }
                return
            }
            
            if let token = token {
                DispatchQueue.main.async {
                    self.updateTokenDisplay(token)
                }
            }
        }
    }
    
    private func updateTokenDisplay(_ token: String) {
        tokenTextView.text = token
        statusLabel.text = "✅ トークン取得成功"
        statusLabel.textColor = .systemGreen
    }
    
    @objc private func fcmTokenUpdated(_ notification: Notification) {
        if let token = notification.userInfo?["token"] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.updateTokenDisplay(token)
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func copyTokenTapped() {
        let token = tokenTextView.text ?? ""
        UIPasteboard.general.string = token
        
        // フィードバック
        let alert = UIAlertController(
            title: "✅ コピー完了",
            message: "FCMトークンをクリップボードにコピーしました",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // ハプティックフィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Notification Handling
    
    @objc private func notificationTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.displayNotificationData(userInfo)
            
            // アラートを表示
            let alert = UIAlertController(
                title: "📬 通知を受信",
                message: "通知がタップされました",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func displayNotificationData(_ userInfo: [AnyHashable: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        var displayText = "受信時刻: \(timestamp)\n\n"
        
        for (key, value) in userInfo {
            displayText += "\(key): \(value)\n"
        }
        
        notificationTextView.text = displayText
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
