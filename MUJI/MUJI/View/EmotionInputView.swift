//
//  EmotionInputView.swift
//  MUJI
//
//  Created by Uihyun.Lee on 3/23/25.
//


import UIKit

class EmotionInputView: UIView {

    // MARK: - UI 요소
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🙂"
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()

    let emotionTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "감정을 간단히 표현해보세요"
            textField.borderStyle = .roundedRect
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.returnKeyType = .done
            textField.clearButtonMode = .whileEditing
            return textField
        }()


    private let emojiOptions: [String] = ["😀", "😡", "😐", "😭", "🤒"]

    private let emojiStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()

    var selectedEmoji: String = "😀"

    // 콜백 클로저 (컨트롤러에서 바인딩 가능)
    var onEmojiSelected: ((String) -> Void)?

    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupEmojiButtons()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        setupEmojiButtons()
    }

    // MARK: - 설정
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4

        addSubview(emojiLabel)
        addSubview(emojiStackView)
        addSubview(emotionTextField)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false
        emotionTextField.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            emojiStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            emojiStackView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            emojiStackView.heightAnchor.constraint(equalToConstant: 40),

            emotionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emotionTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            emotionTextField.topAnchor.constraint(equalTo: emojiStackView.bottomAnchor, constant: 10),
            emotionTextField.heightAnchor.constraint(equalToConstant: 40),
            emotionTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    private func setupEmojiButtons() {
        for emoji in emojiOptions {
            let button = UIButton(type: .system)
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
            emojiStackView.addArrangedSubview(button)
        }
    }

    @objc private func emojiTapped(_ sender: UIButton) {
        guard let emoji = sender.titleLabel?.text else { return }
        selectedEmoji = emoji
        emojiLabel.text = emoji
        onEmojiSelected?(emoji)
    }

    func getEnteredEmotion() -> String {
        return emotionTextField.text ?? ""
    }

    func clear() {
        emotionTextField.text = ""
        selectedEmoji = "🙂"
        emojiLabel.text = "🙂"
    }
}
