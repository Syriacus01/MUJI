import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - 프로퍼티
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // 상단 프로필 정보
    private let profileInfoContainer = UIView()
    private let profileImageView = UIImageView()
    private let profileImageButton = UIButton(type: .system)
    private let statusIndicator = UIView()
    private let nameLabel = UILabel()
    private let nameEditButton = UIButton(type: .system)
    private let usernameLabel = UILabel()
    private let ageLabel = UILabel()
    private let ageEditButton = UIButton(type: .system)
    private let bioLabel = UILabel()
    private let bioEditButton = UIButton(type: .system)
    private let locationLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)
    private let resetProfileButton = UIButton(type: .system)

    // 내부 탭 관련
    private let tabContainerView = UIView()
    private let segmentedControl = UISegmentedControl(items: ["프로필", "감정통계", "플레이리스트"])
    private let containerView = UIView()  // 선택된 탭 콘텐츠를 표시할 뷰

    // 내부 탭의 뷰 컨트롤러들
    private lazy var profileContentVC = ProfileContentViewController()
    private lazy var emotionStatsVC = EmotionStatsViewController()
    private lazy var playlistVC = PlaylistViewController()
    private var currentViewController: UIViewController?

    // 사용자 데이터
    private var name = ""
    private var username = ""
    private var bio = ""
    private var location = ""
    private var age = ""
    private var genres: [String] = []
    private var profileImage: UIImage?

    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        layoutUI()

        // 기본 탭 선택
        segmentedControl.selectedSegmentIndex = 0
        switchTab(to: 0)
    }

    // MARK: - 셋업 메서드
    private func setup() {
        view.backgroundColor = UIColor(
            red: 245 / 255, green: 247 / 255, blue: 250 / 255, alpha: 0.95)
        title = "사용자"

        let editButton = UIBarButtonItem(
            title: "편집", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.rightBarButtonItem = editButton
        
        // UserDefaults에서 데이터 로드
        loadProfileData()
    }
    
    // UserDefaults에서 프로필 데이터 로드
    private func loadProfileData() {
        let userDefaults = UserDefaultsManager.shared
        name = userDefaults.getName()
        //username = userDefaults.getUsername()
        bio = userDefaults.getBio()
        //location = userDefaults.getLocation()
        age = userDefaults.getAge()
        genres = userDefaults.getGenres()
        profileImage = userDefaults.getProfileImage()
    }
    
    // MARK: - 데이터 업데이트 메서드
    
    // 감정 통계 데이터 업데이트
    func updateEmotionData(jsonString: String) {
        emotionStatsVC.updateEmotionData(jsonString: jsonString)
    }
    
    // 활동 데이터 업데이트
    func updateActivityData(jsonString: String) {
        //profileContentVC.updateActivityData(jsonString: jsonString)
    }
    
    // 노래 데이터 업데이트
    func updateSongData(jsonString: String) {
        playlistVC.updateSongData(jsonString: jsonString)
    }

    private func setupUI() {
        // 스크롤뷰 설정
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 프로필 이미지 설정
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        if let profileImage = profileImage {
            profileImageView.image = profileImage
        }
        
        // 프로필 이미지 변경 버튼 설정
        profileImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        profileImageButton.tintColor = .white
        profileImageButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        profileImageButton.layer.cornerRadius = 15
        profileImageButton.addTarget(self, action: #selector(changeProfileImage), for: .touchUpInside)

        // 온라인 상태 인디케이터
        statusIndicator.backgroundColor = UIColor(
            red: 76 / 255, green: 175 / 255, blue: 80 / 255, alpha: 1)
        statusIndicator.layer.cornerRadius = 7
        statusIndicator.layer.borderWidth = 2
        statusIndicator.layer.borderColor = UIColor.white.cgColor

        // 이름 라벨
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = UIColor(red: 44 / 255, green: 62 / 255, blue: 80 / 255, alpha: 1)
        
        // 이름 편집 버튼
        nameEditButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        nameEditButton.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        nameEditButton.addTarget(self, action: #selector(editNameTapped), for: .touchUpInside)

        // 사용자 이름 라벨
        usernameLabel.text = username
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        usernameLabel.textColor = UIColor(
            red: 127 / 255, green: 140 / 255, blue: 141 / 255, alpha: 1)
        
        // 나이 라벨
        ageLabel.text = age
        ageLabel.font = UIFont.systemFont(ofSize: 16)
        ageLabel.textColor = UIColor(red: 44 / 255, green: 62 / 255, blue: 80 / 255, alpha: 1)
        
        // 나이 편집 버튼
        ageEditButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        ageEditButton.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        ageEditButton.addTarget(self, action: #selector(editAgeTapped), for: .touchUpInside)

        // 소개 라벨
        bioLabel.text = bio
        bioLabel.font = UIFont.systemFont(ofSize: 16)
        bioLabel.textColor = UIColor(red: 44 / 255, green: 62 / 255, blue: 80 / 255, alpha: 1)
        bioLabel.numberOfLines = 0
        
        // 소개 편집 버튼
        bioEditButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        bioEditButton.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        bioEditButton.addTarget(self, action: #selector(editBioTapped), for: .touchUpInside)

        // 위치 라벨
        locationLabel.text = location
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = UIColor(
            red: 127 / 255, green: 140 / 255, blue: 141 / 255, alpha: 1)

        // 프로필 편집 버튼
        editProfileButton.setTitle("프로필 편집", for: .normal)
        editProfileButton.backgroundColor = UIColor(
            red: 240 / 255, green: 242 / 255, blue: 245 / 255, alpha: 1)
        editProfileButton.setTitleColor(
            UIColor(red: 44 / 255, green: 62 / 255, blue: 80 / 255, alpha: 1), for: .normal)
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        editProfileButton.layer.cornerRadius = 20
        editProfileButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        // 프로필 초기화 버튼
        resetProfileButton.setTitle("초기화", for: .normal)
        resetProfileButton.backgroundColor = UIColor(
            red: 253 / 255, green: 237 / 255, blue: 237 / 255, alpha: 1)
        resetProfileButton.setTitleColor(
            UIColor(red: 220 / 255, green: 53 / 255, blue: 69 / 255, alpha: 1), for: .normal)
        resetProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        resetProfileButton.layer.cornerRadius = 20
        resetProfileButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        resetProfileButton.addTarget(self, action: #selector(resetProfileTapped), for: .touchUpInside)

        // 세그먼트 컨트롤 설정
        segmentedControl.selectedSegmentTintColor = UIColor(
            red: 88 / 255, green: 126 / 255, blue: 255 / 255, alpha: 1)

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        // 컨테이너 뷰 설정
        containerView.backgroundColor = .clear

        // 각 컨테이너 추가
        contentView.addSubview(profileInfoContainer)
        profileInfoContainer.addSubview(profileImageView)
        profileInfoContainer.addSubview(profileImageButton)
        profileInfoContainer.addSubview(statusIndicator)
        profileInfoContainer.addSubview(nameLabel)
        profileInfoContainer.addSubview(nameEditButton)
        profileInfoContainer.addSubview(usernameLabel)
        profileInfoContainer.addSubview(editProfileButton)

        contentView.addSubview(ageLabel)
        contentView.addSubview(ageEditButton)
        contentView.addSubview(bioLabel)
        contentView.addSubview(bioEditButton)
        contentView.addSubview(locationLabel)
        contentView.addSubview(resetProfileButton)

        contentView.addSubview(tabContainerView)
        tabContainerView.addSubview(segmentedControl)
        tabContainerView.addSubview(containerView)
        
        // 프로필 이미지 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - 레이아웃 메서드
    private func layoutUI() {
        // 기본 레이아웃 요소 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameEditButton.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageEditButton.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioEditButton.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        resetProfileButton.translatesAutoresizingMaskIntoConstraints = false
        tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

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

            // 프로필 정보 컨테이너
            profileInfoContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileInfoContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            profileInfoContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),

            // 프로필 이미지
            profileImageView.topAnchor.constraint(equalTo: profileInfoContainer.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: profileInfoContainer.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // 프로필 이미지 변경 버튼
            profileImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -2),
            profileImageButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -2),
            profileImageButton.widthAnchor.constraint(equalToConstant: 30),
            profileImageButton.heightAnchor.constraint(equalToConstant: 30),

            // 상태 인디케이터
            statusIndicator.bottomAnchor.constraint(
                equalTo: profileImageView.bottomAnchor, constant: -2),
            statusIndicator.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor, constant: 2),
            statusIndicator.heightAnchor.constraint(equalToConstant: 14),
            statusIndicator.widthAnchor.constraint(equalToConstant: 14),

            // 이름 라벨
            nameLabel.topAnchor.constraint(equalTo: profileInfoContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(
                equalTo: profileImageView.trailingAnchor, constant: 15),
                
            // 이름 편집 버튼
            nameEditButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nameEditButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            nameEditButton.widthAnchor.constraint(equalToConstant: 24),
            nameEditButton.heightAnchor.constraint(equalToConstant: 24),

            // 사용자 이름 라벨
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // 편집 버튼
            editProfileButton.centerYAnchor.constraint(equalTo: profileInfoContainer.centerYAnchor),
            editProfileButton.trailingAnchor.constraint(
                equalTo: profileInfoContainer.trailingAnchor),

            // 프로필 컨테이너 높이
            profileInfoContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // 나이 라벨
            ageLabel.topAnchor.constraint(equalTo: profileInfoContainer.bottomAnchor, constant: 16),
            ageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // 나이 편집 버튼
            ageEditButton.centerYAnchor.constraint(equalTo: ageLabel.centerYAnchor),
            ageEditButton.leadingAnchor.constraint(equalTo: ageLabel.trailingAnchor, constant: 8),
            ageEditButton.widthAnchor.constraint(equalToConstant: 24),
            ageEditButton.heightAnchor.constraint(equalToConstant: 24),

            // 자기 소개
            bioLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // 소개 편집 버튼
            bioEditButton.topAnchor.constraint(equalTo: bioLabel.topAnchor),
            bioEditButton.leadingAnchor.constraint(equalTo: bioLabel.trailingAnchor, constant: 4),
            bioEditButton.widthAnchor.constraint(equalToConstant: 24),
            bioEditButton.heightAnchor.constraint(equalToConstant: 24),

            // 위치
            locationLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
                
            // 초기화 버튼
            resetProfileButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            resetProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 탭 컨테이너
            tabContainerView.topAnchor.constraint(
                equalTo: resetProfileButton.bottomAnchor, constant: 16),
            tabContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tabContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tabContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // 세그먼트 컨트롤
            segmentedControl.topAnchor.constraint(equalTo: tabContainerView.topAnchor),
            segmentedControl.leadingAnchor.constraint(
                equalTo: tabContainerView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(
                equalTo: tabContainerView.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),

            // 컨테이너 뷰
            containerView.topAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: tabContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: tabContainerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabContainerView.bottomAnchor),
            // 컨테이너 뷰 높이 (필요에 따라 조정)
            containerView.heightAnchor.constraint(equalToConstant: 500),
        ])
    }
    
    // 프로필 UI 업데이트
    private func updateProfileUI() {
        nameLabel.text = name
        usernameLabel.text = username
        bioLabel.text = bio
        locationLabel.text = location
        ageLabel.text = age
        profileImageView.image = profileImage
        
        // 프로필 컨텐츠 뷰에 장르 업데이트
        profileContentVC.updateGenres(genres)
    }

    // MARK: - 탭 전환 메서드
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switchTab(to: sender.selectedSegmentIndex)
    }

    private func switchTab(to index: Int) {
        // 현재 표시된 뷰 컨트롤러 제거
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }

        // 새 뷰 컨트롤러 표시
        let newVC: UIViewController
        switch index {
        case 0:
            newVC = profileContentVC
        case 1:
            newVC = emotionStatsVC
        case 2:
            newVC = playlistVC
        default:
            newVC = profileContentVC
        }

        addChild(newVC)
        newVC.view.frame = containerView.bounds
        containerView.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        // 자식 뷰 컨트롤러의 뷰가 컨테이너 뷰의 크기에 맞도록 설정
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        currentViewController = newVC
    }

    // MARK: - 액션 메서드
    @objc private func editProfileTapped() {
        let profileEditVC = ProfileEditViewController()
        profileEditVC.delegate = self
        profileEditVC.setProfileImage(profileImage)
        let navController = UINavigationController(rootViewController: profileEditVC)
        present(navController, animated: true)
    }
    
    @objc private func resetProfileTapped() {
        let alert = UIAlertController(title: "프로필 초기화", message: "프로필 정보를 기본값으로 초기화하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let resetAction = UIAlertAction(title: "초기화", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 프로필 데이터 초기화
            UserDefaultsManager.shared.resetProfileToDefaults()
            
            // 데이터 다시 로드
            self.loadProfileData()
            
            // UI 업데이트
            self.updateProfileUI()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(resetAction)
        
        present(alert, animated: true)
    }
    
    @objc private func changeProfileImage() {
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
            UserDefaultsManager.shared.saveProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImage = originalImage
            profileImageView.image = originalImage
            UserDefaultsManager.shared.saveProfileImage(originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @objc private func editNameTapped() {
        let alert = UIAlertController(title: "이름 수정", message: "새로운 이름을 입력하세요", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.name
            textField.placeholder = "이름"
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newName = textField.text, !newName.isEmpty else { return }
            
            // 새 이름 저장
            self.name = newName
            UserDefaultsManager.shared.saveName(newName)
            
            // UI 업데이트
            self.nameLabel.text = newName
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    @objc private func editAgeTapped() {
        let alert = UIAlertController(title: "나이 수정", message: "새로운 나이를 입력하세요", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.age
            textField.placeholder = "나이"
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newAge = textField.text, !newAge.isEmpty else { return }
            
            // 새 나이 저장
            self.age = newAge
            UserDefaultsManager.shared.saveAge(newAge)
            
            // UI 업데이트
            self.ageLabel.text = newAge
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    @objc private func editBioTapped() {
        let alert = UIAlertController(title: "소개 수정", message: "새로운 소개를 입력하세요", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.bio
            textField.placeholder = "소개"
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newBio = textField.text, !newBio.isEmpty else { return }
            
            // 새 소개 저장
            self.bio = newBio
            UserDefaultsManager.shared.saveBio(newBio)
            
            // UI 업데이트
            self.bioLabel.text = newBio
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
}

// MARK: - ProfileEditViewControllerDelegate
extension ProfileViewController: ProfileEditViewControllerDelegate {
    func didUpdateProfile(name: String, age: String, genres: [String], image: UIImage?) {
        self.name = name
        self.age = age
        self.genres = genres
        
        if let newImage = image {
            self.profileImage = newImage
        }

        // UI 업데이트
        nameLabel.text = name
        ageLabel.text = age
        if let newImage = image {
            profileImageView.image = newImage
        }
        profileContentVC.updateGenres(genres)
        
        // UserDefaults에 저장
        UserDefaultsManager.shared.saveProfile(name: name, age: age, genres: genres, image: image)
    }
}
