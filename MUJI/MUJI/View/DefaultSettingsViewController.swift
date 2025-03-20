//
//  DefaultSettingsViewController.swift
//  MUJI
//
//  Created by 원대한 on 3/18/25.
//


import UIKit

class DefaultSettingsViewController: UIViewController {
    // MARK: - 프로퍼티
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let formContainerView = UIView()
    
    private let titleLabel = UILabel()
    
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    
    private let ageLabel = UILabel()
    private let ageTextField = UITextField()
    
    private let bioLabel = UILabel()
    private let bioTextView = UITextView()
    
    private let resetButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        layoutUI()
        loadDefaultValues()
    }
    
    // MARK: - 셋업 메서드
    private func setup() {
        view.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 0.95)
        title = "기본값 설정"
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    // UserDefaults에서 기본값 로드
    private func loadDefaultValues() {
        let manager = UserDefaultsManager.shared
        nameTextField.text = manager.getDefaultName()
        ageTextField.text = manager.getDefaultAge()
        bioTextView.text = manager.getDefaultBio()
    }
    
    private func setupUI() {
        // 스크롤뷰 설정
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 타이틀 레이블
        titleLabel.text = "기본값 설정"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        
        // 폼 컨테이너
        formContainerView.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 0.05)
        formContainerView.layer.cornerRadius = 16
        
        // 이름 설정
        nameLabel.text = "기본 이름"
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        nameTextField.placeholder = "기본 이름을 입력하세요"
        nameTextField.font = UIFont.systemFont(ofSize: 16)
        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = .white
        
        // 나이 설정
        ageLabel.text = "기본 나이"
        ageLabel.font = UIFont.systemFont(ofSize: 14)
        ageLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        ageTextField.placeholder = "기본 나이를 입력하세요"
        ageTextField.font = UIFont.systemFont(ofSize: 16)
        ageTextField.borderStyle = .roundedRect
        ageTextField.backgroundColor = .white
        
        // 소개 설정
        bioLabel.text = "기본 소개"
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        bioTextView.font = UIFont.systemFont(ofSize: 16)
        bioTextView.layer.borderWidth = 0.5
        bioTextView.layer.borderColor = UIColor.lightGray.cgColor
        bioTextView.layer.cornerRadius = 5
        bioTextView.backgroundColor = .white
        
        // 저장 버튼
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 초기화 버튼
        resetButton.setTitle("초기 설정으로 되돌리기", for: .normal)
        resetButton.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 237/255, alpha: 1)
        resetButton.setTitleColor(UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1), for: .normal)
        resetButton.layer.cornerRadius = 10
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // 뷰 계층 구조 설정
        contentView.addSubview(titleLabel)
        contentView.addSubview(formContainerView)
        
        formContainerView.addSubview(nameLabel)
        formContainerView.addSubview(nameTextField)
        formContainerView.addSubview(ageLabel)
        formContainerView.addSubview(ageTextField)
        formContainerView.addSubview(bioLabel)
        formContainerView.addSubview(bioTextView)
        formContainerView.addSubview(saveButton)
        formContainerView.addSubview(resetButton)
    }
    
    // MARK: - 레이아웃 메서드
    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 스크롤뷰
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 콘텐츠뷰
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 타이틀
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 폼 컨테이너
            formContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
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
            
            // 소개 라벨
            bioLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            
            // 소개 텍스트뷰
            bioTextView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 8),
            bioTextView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            bioTextView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            bioTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // 저장 버튼
            saveButton.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 초기화 버튼
            resetButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            resetButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 액션 메서드
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let age = ageTextField.text, !age.isEmpty,
              let bio = bioTextView.text, !bio.isEmpty else {
            
            let alert = UIAlertController(title: "입력 오류", message: "모든 필드를 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        // UserDefaults에 기본값 저장
        let manager = UserDefaultsManager.shared
        manager.saveDefaultName(name)
        manager.saveDefaultAge(age)
        manager.saveDefaultBio(bio)
        
        // 저장 성공 알림
        let alert = UIAlertController(title: "저장 완료", message: "기본값이 저장되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        // 초기화 확인 알림
        let alert = UIAlertController(title: "초기화 확인", message: "기본값을 초기 설정으로 되돌리시겠습니까?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // UserDefaults에서 기본값 키 삭제
            UserDefaults.standard.removeObject(forKey: "default_name")
            UserDefaults.standard.removeObject(forKey: "default_age")
            UserDefaults.standard.removeObject(forKey: "default_bio")
            UserDefaults.standard.removeObject(forKey: "defaults_initialized")
            
            // 기본값 다시 로드
            self.loadDefaultValues()
            
            // 초기화 완료 알림
            let confirmAlert = UIAlertController(title: "초기화 완료", message: "기본값이 초기 설정으로 되돌아갔습니다.", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(confirmAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
}
