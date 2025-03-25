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

class ReasonLabelTapGestureRecognizer: UITapGestureRecognizer {
    var relatedTitleLabel: UILabel?
}

class MujiEmotionMapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    private var sheetController: UISheetPresentationController?
    private let emotionViewModel = EmotionViewModel.shared
    private let fetchWeather = FetchWeather.shared
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?

    private var selectedEmoji: String = "🙂"

    private let titleLabel: UILabel = {
        let label = UILabel()
        let titles = [
            "지금 내 마음은?",
            "니 심정 어때?",
            "너의 마음 상태를 눌러봐",
            "오늘 하루는 어땠어?"
        ]
        label.text = titles.randomElement() ?? "감정지도"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    private let emotionInputView = EmotionInputView()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("검색", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let recommendationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        emotionInputView.emotionTextField.delegate = self
        emotionInputView.emotionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        setupUI()
        UserViewModel.shared.fetchUser()

        emotionInputView.onEmojiSelected = { [weak self] emoji in
            self?.selectedEmoji = emoji
        }

        if let sheet = self.presentationController as? UISheetPresentationController {
            self.sheetController = sheet
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        let trimmed = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        saveButton.isEnabled = !trimmed.isEmpty
        saveButton.backgroundColor = trimmed.isEmpty ? .lightGray : .systemBlue
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func setupUI() {
        [titleLabel, emotionInputView, saveButton, loadingIndicator, recommendationStackView, toastLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            emotionInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emotionInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emotionInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            emotionInputView.heightAnchor.constraint(equalToConstant: 180),

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

    @objc private func saveEmotion() {
        view.endEditing(true)

        let emoji = selectedEmoji
        let rawText = emotionInputView.emotionTextField.text ?? ""
        let emotionText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !emotionText.isEmpty else {
            showToast(message: "감정을 입력해주세요")
            return
        }

        guard let location = currentLocation else {
            showToast(message: "위치 정보를 가져올 수 없습니다.")
            return
        }

        EmotionViewModel.shared.addEmotion(
            emotion: emoji,
            comment: emotionText,
            latitude: location.latitude,
            longitude: location.longitude
        )

        guard let latestEmotion = EmotionViewModel.shared.emotions.last else {
            showToast(message: "최근 감정 데이터를 찾을 수 없습니다.")
            return
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window,
           let rootVC = window.rootViewController as? MujiMainViewController {
            rootVC.addEmojiAnnotation(emoji: emoji, emotion: emotionText)
            rootVC.changeSheetToLargeSize()
        }

        loadingIndicator.startAnimating()
        recommendationStackView.isHidden = true
        recommendationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        EmotionRecommendationManager.shared.getRecommendation(
            emotion: emoji,
            comment: emotionText,
            location: location,
            user: UserViewModel.shared.user
        ) { [weak self] (lines: [String]) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()

                if lines.isEmpty {
                    let label = UILabel()
                    label.text = "추천 결과가 없습니다."
                    label.font = UIFont.systemFont(ofSize: 16)
                    self.recommendationStackView.addArrangedSubview(label)
                } else {
                    for i in stride(from: 0, to: lines.count, by: 2) {
                        let title = lines[safe: i] ?? ""
                        let reason = lines[safe: i + 1] ?? ""

                        let container = UIStackView()
                        container.axis = .vertical
                        container.spacing = 4

                        let titleLabel = UILabel()
                        let cleanedTitle = title.replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression)
                        titleLabel.text = "\u{1F3B5} " + cleanedTitle
                        titleLabel.font = UIFont.systemFont(ofSize: 18)
                        titleLabel.isUserInteractionEnabled = true
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.copySongText(_:)))
                        titleLabel.addGestureRecognizer(tap)

                        let reasonLabel = UILabel()
                        reasonLabel.text = reason
                        reasonLabel.font = UIFont.systemFont(ofSize: 13)
                        reasonLabel.textColor = .gray
                        reasonLabel.numberOfLines = 0
                        reasonLabel.isUserInteractionEnabled = true

                        let reasonTap = ReasonLabelTapGestureRecognizer(target: self, action: #selector(self.copyReasonRelatedTitle(_:)))
                        reasonTap.relatedTitleLabel = titleLabel
                        reasonLabel.addGestureRecognizer(reasonTap)

                        container.addArrangedSubview(titleLabel)
                        container.addArrangedSubview(reasonLabel)

                        self.recommendationStackView.addArrangedSubview(container)
                    }
                }
                self.recommendationStackView.isHidden = false
            }
        }
    }

    @objc private func copySongText(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let text = label.text else { return }

        let copiedText = text.replacingOccurrences(of: "\u{1F3B5} ", with: "")
        UIPasteboard.general.string = copiedText
        showToast(message: "\(copiedText) 복사되었습니다.")
    }

    @objc private func copyReasonRelatedTitle(_ sender: ReasonLabelTapGestureRecognizer) {
        guard let label = sender.relatedTitleLabel,
              let text = label.text else { return }

        let copiedText = text.replacingOccurrences(of: "\u{1F3B5} ", with: "")
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보 가져오기 실패: \(error)")
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
