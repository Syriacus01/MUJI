import UIKit
import MapKit

//UILabel을 이미지로 변환하는 확장 메서드
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
    private var isSmallDetent = true
    private let emotionViewModel = TestEmotionViewModel()
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
        label.text = "🙂" // 기본 이모지
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 선택 가능한 이모지 버튼들
    private let emojiOptions: [String] = ["😀", "😢", "😡", "😱", "😍"]
    private var selectedEmoji: String = "🙂" // 기본값
    
    private let emojiStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        emotionViewModel.requestLocation()
        // 현재 시트의 UISheetPresentationController 가져오기
        if let sheet = self.presentationController as? UISheetPresentationController {
            self.sheetController = sheet
        }
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emotionInputView.translatesAutoresizingMaskIntoConstraints = false
        emotionTextField.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(emotionInputView)
        view.addSubview(saveButton)
        
        emotionInputView.addSubview(emojiLabel)
        emotionInputView.addSubview(emotionTextField)
        emotionInputView.addSubview(emojiStackView)
        
        // 이모지 선택 버튼 추가
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
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        saveButton.addTarget(self, action: #selector(saveEmotion), for: .touchUpInside)
    }
    
    //이모지 선택 버튼 클릭 시 변경
    @objc private func emojiSelected(_ sender: UIButton) {
        guard let emoji = sender.titleLabel?.text else { return }
        selectedEmoji = emoji
        emojiLabel.text = emoji
    }
    
    //저장 버튼 클릭 시 현재 위치에 이모지를 핀으로 추가
    @objc private func saveEmotion() {
        let emoji = selectedEmoji
                let emotionText = emotionTextField.text ?? ""
                
                // 감정 데이터 저장 및 콘솔 출력
                emotionViewModel.saveEmotion(emoji: emoji, emotion: emotionText)
                
                // 저장 후 지도에 핀 추가
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window,
                   let rootVC = window.rootViewController as? MujiMainViewController {
                    
                    rootVC.addEmojiAnnotation(emoji: emoji, emotion: emotionText)
                    rootVC.changeSheetToSmallSize()
        }
    }
}
