import UIKit
import SwiftUI

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - 프로퍼티
    weak var delegate: ProfileEditViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let profileImageChangeButton = UIButton(type: .system)
    private let formContainerView = UIView()
    
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    
    private let ageLabel = UILabel()
    private let ageTextField = UITextField()
    
    private let genreLabel = UILabel()
    private let genreContainerView = UIView() // 장르 버튼들을 담는 컨테이너
    private let helperTextLabel = UILabel()
    
    // 장르 데이터 및 상태
    // 주석: 원하는 장르를 추가/제거하여 선택 항목을 변경할 수 있습니다
    private let allGenres = ["팝", "K-POP", "재즈", "클래식", "R&B", "힙합", "발라드", "트로트", "록", "OST", "인디", "댄스"]
    // 주석: 초기 선택된 장르 설정 (최대 3개까지 가능)
    private var selectedGenres: [String] = []
    // 주석: 생성된 버튼들을 추적하기 위한 배열 추가
    private var genreButtons: [UIButton] = []
    // 프로필 이미지 추적
    private var profileImage: UIImage?
    
    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        layoutUI()
    }
    
    // MARK: - 셋업 메서드
    private func setup() {
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        title = "프로필 편집"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
        
        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        // UserDefaults에서 데이터 로드
        loadProfileData()
        
        // 기본 이미지 로드
        profileImage = UserDefaultsManager.shared.getProfileImage()
    }
    
    // UserDefaults에서 저장된 데이터 로드
    private func loadProfileData() {
        selectedGenres = UserDefaultsManager.shared.getGenres()
    }
    
    // 외부에서 프로필 이미지 설정
    func setProfileImage(_ image: UIImage?) {
        profileImage = image
        if isViewLoaded {
            profileImageView.image = image
        }
    }
    
    private func setupUI() {
        // 스크롤뷰 설정
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 프로필 이미지
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        
        // 저장된 프로필 이미지가 있는 경우 설정
        if let profileImage = profileImage {
            profileImageView.image = profileImage
        }
        
        // 이미지 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // 프로필 이미지 변경 버튼
        profileImageChangeButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        profileImageChangeButton.tintColor = .white
        profileImageChangeButton.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 0.8)
        profileImageChangeButton.layer.cornerRadius = 15
        profileImageChangeButton.addTarget(self, action: #selector(changeProfileImageTapped), for: .touchUpInside)
        
        // 폼 컨테이너 뷰
        formContainerView.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 0.05)
        formContainerView.layer.cornerRadius = 16
        
        // 이름 라벨
        nameLabel.text = "이름"
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        // 이름 텍스트필드
        // UserDefaults에서 저장된 이름 사용
        nameTextField.placeholder = "이름을 입력하세요"
        nameTextField.text = UserDefaultsManager.shared.getName()
        nameTextField.font = UIFont.systemFont(ofSize: 16)
        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = UIColor.white
        
        // 나이 라벨
        ageLabel.text = "나이"
        ageLabel.font = UIFont.systemFont(ofSize: 14)
        ageLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        // 나이 텍스트필드
        ageTextField.placeholder = "나이를 입력하세요"
        ageTextField.text = UserDefaultsManager.shared.getAge()
        ageTextField.font = UIFont.systemFont(ofSize: 16)
        ageTextField.borderStyle = .roundedRect
        ageTextField.backgroundColor = UIColor.white
        
        // 장르 라벨
        genreLabel.text = "선호하는 음악 장르"
        genreLabel.font = UIFont.systemFont(ofSize: 14)
        genreLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        // 헬퍼 텍스트
        helperTextLabel.text = "원하는 장르를 선택해주세요 (최대 3개)"
        helperTextLabel.font = UIFont.systemFont(ofSize: 12)
        helperTextLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        // 각 뷰 추가
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileImageChangeButton)
        contentView.addSubview(formContainerView)
        
        formContainerView.addSubview(nameLabel)
        formContainerView.addSubview(nameTextField)
        formContainerView.addSubview(ageLabel)
        formContainerView.addSubview(ageTextField)
        formContainerView.addSubview(genreLabel)
        formContainerView.addSubview(genreContainerView)
        formContainerView.addSubview(helperTextLabel)
        
        // 장르 칩 셋업
        setupGenreChips()
    }
    
    private func setupGenreChips() {
        // 기존 서브뷰 제거
        genreContainerView.subviews.forEach { $0.removeFromSuperview() }
        genreButtons.removeAll()
        
        // 주석: 스택뷰를 사용하여 장르 칩을 여러 행으로 자연스럽게 배치
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.alignment = .leading
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        genreContainerView.addSubview(containerStackView)
        
        // 현재 행 스택뷰
        var currentRowStackView = UIStackView()
        currentRowStackView.axis = .horizontal
        currentRowStackView.spacing = 12
        currentRowStackView.alignment = .center
        
        var currentRowWidth: CGFloat = 0
        let maxRowWidth = UIScreen.main.bounds.width - 60  // 화면 너비 - 좌우 패딩
        
        // 모든 장르 버튼 생성
        for genre in allGenres {
            let isSelected = selectedGenres.contains(genre)
            
            // 주석: 각 장르 버튼의 디자인을 여기서 커스터마이즈할 수 있습니다
            let chipButton = UIButton(type: .system)
            chipButton.setTitle(genre, for: .normal)
            chipButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            // 선택 상태에 따른 스타일 설정
            updateButtonStyle(chipButton, isSelected: isSelected)
            
            // 여백 및 라운드 설정
            chipButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            chipButton.layer.cornerRadius = 20
            chipButton.clipsToBounds = true
            
            // 액션 추가
            chipButton.tag = allGenres.firstIndex(of: genre) ?? 0
            chipButton.addTarget(self, action: #selector(genreChipTapped(_:)), for: .touchUpInside)
            
            // 버튼 크기 계산
            chipButton.sizeToFit()
            let buttonWidth = chipButton.frame.size.width + 40  // 내부 패딩 고려
            
            // 현재 행에 추가할 수 없으면 새 행 시작
            if currentRowWidth + buttonWidth > maxRowWidth && currentRowStackView.arrangedSubviews.count > 0 {
                containerStackView.addArrangedSubview(currentRowStackView)
                
                currentRowStackView = UIStackView()
                currentRowStackView.axis = .horizontal
                currentRowStackView.spacing = 12
                currentRowStackView.alignment = .center
                
                currentRowWidth = 0
            }
            
            currentRowStackView.addArrangedSubview(chipButton)
            currentRowWidth += buttonWidth + 12  // 버튼 너비 + 스택뷰 간격
            
            // 버튼 추적 배열에 추가
            genreButtons.append(chipButton)
        }
        
        // 마지막 행 추가
        if currentRowStackView.arrangedSubviews.count > 0 {
            containerStackView.addArrangedSubview(currentRowStackView)
        }
        
        // 스택뷰 제약조건 설정
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: genreContainerView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: genreContainerView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: genreContainerView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: genreContainerView.bottomAnchor)
        ])
    }
    
    // 주석: 버튼 스타일을 업데이트하는 별도 함수로 분리하여 코드 중복 방지
    private func updateButtonStyle(_ button: UIButton, isSelected: Bool) {
        // 선택 상태에 따른 색상 및 폰트 설정
        if isSelected {
            button.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1), for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 0.5).cgColor
        }
    }
    
    // MARK: - 레이아웃 메서드
    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageChangeButton.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genreContainerView.translatesAutoresizingMaskIntoConstraints = false
        helperTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 스크롤뷰 제약조건
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 콘텐츠뷰 제약조건
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 프로필 이미지
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // 프로필 이미지 변경 버튼
            profileImageChangeButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            profileImageChangeButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5),
            profileImageChangeButton.widthAnchor.constraint(equalToConstant: 30),
            profileImageChangeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 폼 컨테이너
            formContainerView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            formContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // 이름 라벨
            nameLabel.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            
            // 이름 텍스트필드
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 나이 라벨
            ageLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            ageLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            ageLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            
            // 나이 텍스트필드
            ageTextField.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 8),
            ageTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            ageTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            ageTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 장르 라벨
            genreLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 16),
            genreLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            genreLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            
            // 장르 컨테이너
            genreContainerView.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 12),
            genreContainerView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            genreContainerView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            
            // 헬퍼 텍스트
            helperTextLabel.topAnchor.constraint(equalTo: genreContainerView.bottomAnchor, constant: 12),
            helperTextLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            helperTextLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            helperTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: formContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 액션 메서드
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            let alert = UIAlertController(title: "알림", message: "이름을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let age = ageTextField.text, !age.isEmpty else {
            let alert = UIAlertController(title: "알림", message: "나이를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        delegate?.didUpdateProfile(name: name, age: age, genres: selectedGenres, image: profileImage)
        dismiss(animated: true)
    }
    
    @objc private func changeProfileImageTapped() {
        let alertController = UIAlertController(title: "프로필 사진 변경", message: "프로필 사진을 어떻게 변경하시겠습니까?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
                self?.showImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        
        let galleryAction = UIAlertAction(title: "갤러리", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = profileImageView
                popoverController.sourceRect = profileImageView.bounds
            }
        }
        
        present(alertController, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            profileImage = editedImage
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImage = originalImage
            profileImageView.image = originalImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @objc private func genreChipTapped(_ sender: UIButton) {
        guard let index = sender.tag as? Int, index < allGenres.count else { return }
        
        let genre = allGenres[index]
        
        if selectedGenres.contains(genre) {
            // 이미 선택된 장르라면 제거
            if let index = selectedGenres.firstIndex(of: genre) {
                selectedGenres.remove(at: index)
                updateButtonStyle(sender, isSelected: false)
            }
        } else {
            // 새로 선택된 장르라면 추가 (최대 3개까지)
            if selectedGenres.count < 3 {
                selectedGenres.append(genre)
                updateButtonStyle(sender, isSelected: true)
            } else {
                // 이미 3개가 선택된 경우 알림
                let alert = UIAlertController(title: "알림", message: "장르는 최대 3개까지 선택 가능합니다", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
                return
            }
        }
    }
}
