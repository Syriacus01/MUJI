import UIKit
import MapKit

extension UILabel {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

class MujiEmotionMapViewController: UIViewController {

    private var sheetController: UISheetPresentationController?
    private let emotionViewModel = TestEmotionViewModel()
    private var selectedEmoji: String = "🙂"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "감정지도"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let emotionInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let emotionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "감정을 입력하세요"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🙂"
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("검색", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    private let emojiOptions: [String] = ["😀", "😢", "😡", "😱", "😍"]

    private let emojiStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let recommendationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.isHidden = true
        return stackView
    }()

    private let toastLabel: UILabel = {
        let label = UILabel()
        label.text = "복사되었습니다"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textColor = .white
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.alpha = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        emotionViewModel.requestLocation()
        setupUI()

        if let sheet = self.presentationController as? UISheetPresentationController {
            self.sheetController = sheet
        }
    }

    private func setupUI() {
        [titleLabel, emotionInputView, saveButton, loadingIndicator, recommendationStackView, toastLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [emojiLabel, emotionTextField, emojiStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            emotionInputView.addSubview($0)
        }

        for emoji in emojiOptions {
            let button = UIButton(type: .system)
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.addTarget(self, action: #selector(emojiSelected(_:)), for: .touchUpInside)
            emojiStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            emotionInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emotionInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emotionInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            emotionInputView.heightAnchor.constraint(equalToConstant: 180),

            emojiLabel.centerXAnchor.constraint(equalTo: emotionInputView.centerXAnchor),
            emojiLabel.topAnchor.constraint(equalTo: emotionInputView.topAnchor, constant: 10),

            emojiStackView.leadingAnchor.constraint(equalTo: emotionInputView.leadingAnchor, constant: 10),
            emojiStackView.trailingAnchor.constraint(equalTo: emotionInputView.trailingAnchor, constant: -10),
            emojiStackView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            emojiStackView.heightAnchor.constraint(equalToConstant: 40),

            emotionTextField.leadingAnchor.constraint(equalTo: emotionInputView.leadingAnchor, constant: 10),
            emotionTextField.trailingAnchor.constraint(equalTo: emotionInputView.trailingAnchor, constant: -10),
            emotionTextField.topAnchor.constraint(equalTo: emojiStackView.bottomAnchor, constant: 10),
            emotionTextField.heightAnchor.constraint(equalToConstant: 40),

            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: emotionInputView.bottomAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),

            recommendationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recommendationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recommendationStackView.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10),

            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])

        saveButton.addTarget(self, action: #selector(saveEmotion), for: .touchUpInside)
    }

    @objc private func emojiSelected(_ sender: UIButton) {
        guard let emoji = sender.titleLabel?.text else { return }
        selectedEmoji = emoji
        emojiLabel.text = emoji
    }

    @objc private func saveEmotion() {
        let emoji = selectedEmoji
        let emotionText = emotionTextField.text ?? ""
        emotionViewModel.saveEmotion(emoji: emoji, emotion: emotionText)

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window,
           let rootVC = window.rootViewController as? MujiMainViewController {
            rootVC.addEmojiAnnotation(emoji: emoji, emotion: emotionText)
            rootVC.changeSheetToLargeSize()
        }

        loadingIndicator.startAnimating()
        recommendationStackView.isHidden = true
        recommendationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        Task {
            let result = await SearchChatGPT.shared.search(
                location: "한국",
                weather: "비오는날",
                emotion: "기쁨",
                age: 20,
                genre: "j-pop"
            )

            let lines = result.split(separator: "\n").map { String($0) }

            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()

                if lines.isEmpty {
                    let label = UILabel()
                    label.text = "추천 결과가 없습니다."
                    label.font = UIFont.systemFont(ofSize: 16)
                    self.recommendationStackView.addArrangedSubview(label)
                } else {
                    for song in lines {
                        let label = UILabel()
                        label.text = "🎵 " + song
                        label.font = UIFont.systemFont(ofSize: 18)
                        label.isUserInteractionEnabled = true

                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.copySongText(_:)))
                        label.addGestureRecognizer(tap)

                        self.recommendationStackView.addArrangedSubview(label)
                    }
                }

                self.recommendationStackView.isHidden = false
            }
        }
    }

    @objc private func copySongText(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let text = label.text else { return }

        let copiedText = text.replacingOccurrences(of: "🎵 ", with: "")
        UIPasteboard.general.string = copiedText

        showToast(message: "\(copiedText) 복사되었습니다.")
    }

    func showToast(message: String, font: UIFont = .systemFont(ofSize: 14)) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.font = font
        toastLabel.alpha = 0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        // 사이즈 자동 계산
        let maxWidth: CGFloat = view.frame.width - 40
        let textSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        let labelWidth = min(maxWidth, textSize.width + 32)
        let labelHeight = textSize.height + 20

        toastLabel.frame = CGRect(
            x: (view.frame.width - labelWidth) / 2,
            y: view.frame.height - 120,
            width: labelWidth,
            height: labelHeight
        )

        view.addSubview(toastLabel)

        // 초기 위치 아래쪽
        toastLabel.transform = CGAffineTransform(translationX: 0, y: 25)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
            toastLabel.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.3, animations: {
                    toastLabel.alpha = 0
                    toastLabel.transform = CGAffineTransform(translationX: 0, y: 20)
                }, completion: { _ in
                    toastLabel.removeFromSuperview()
                })
            }
        }
    }


}
