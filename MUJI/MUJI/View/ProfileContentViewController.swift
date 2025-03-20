//
//  ProfileContentViewController.swift
//  MUJI
//
//  Created by 원대한 on 3/19/25.
//


//
//  ProfileContentViewController.swift
//  NoStoryboardProject01
//
//  Created by 원대한 on 3/17/25.
//


import UIKit
import SwiftUI

class ProfileContentViewController: UIViewController {
    // MARK: - 프로퍼티
    private let genreContainerView = UIView()
    private let genreTitleLabel = UILabel()
    private var genreStackView = UIStackView()
    
    private let activityContainerView = UIView()
    private let activityTitleLabel = UILabel()
    
    // 사용자 데이터 - UserDefaults에서 로드
    private var genres: [String] = []
    
    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        // UserDefaults에서 장르 데이터 로드
        genres = UserDefaultsManager.shared.getGenres()
        setupUI()
        layoutUI()
    }
    
    // MARK: - 셋업 메서드
    private func setupUI() {
        view.backgroundColor = .clear
        
        // 장르 섹션 타이틀
        genreTitleLabel.text = "선호하는 음악 장르"
        genreTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        genreTitleLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
        
        // 장르 스택뷰
        genreStackView.axis = .vertical
        genreStackView.spacing = 8
        genreStackView.distribution = .fillEqually
        
        // 활동 섹션 타이틀
        activityTitleLabel.text = "최근 활동"
        activityTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        activityTitleLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
        
        // 각 컨테이너 추가
        view.addSubview(genreContainerView)
        genreContainerView.addSubview(genreTitleLabel)
        genreContainerView.addSubview(genreStackView)
        
        view.addSubview(activityContainerView)
        activityContainerView.addSubview(activityTitleLabel)
        
        // 장르 추가
        setupGenres()
        
        // 최근 활동 추가
        addActivityItem(icon: "music.note", text: "새로운 플레이리스트 '차분한 아침' 생성", time: "2시간 전")
    }
    
    private func setupGenres() {
        // 기존 스택뷰의 서브뷰 제거
        genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 각 장르별 뷰 생성 및 추가
        for genre in genres {
            let genreView = UIView()
            genreView.backgroundColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 0.1)
            genreView.layer.cornerRadius = 12
            
            let genreLabel = UILabel()
            genreLabel.text = genre
            genreLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            genreLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
            
            let editButton = UIButton(type: .system)
            editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            editButton.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
            editButton.tag = genres.firstIndex(of: genre) ?? 0
            editButton.addTarget(self, action: #selector(editGenreTapped(_:)), for: .touchUpInside)
            
            genreView.addSubview(genreLabel)
            genreView.addSubview(editButton)
            
            // 제약조건 설정
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
            editButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                genreLabel.leadingAnchor.constraint(equalTo: genreView.leadingAnchor, constant: 12),
                genreLabel.centerYAnchor.constraint(equalTo: genreView.centerYAnchor),
                
                editButton.trailingAnchor.constraint(equalTo: genreView.trailingAnchor, constant: -12),
                editButton.centerYAnchor.constraint(equalTo: genreView.centerYAnchor),
                editButton.widthAnchor.constraint(equalToConstant: 24),
                editButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            // 스택뷰에 추가
            genreStackView.addArrangedSubview(genreView)
            
            // 높이 제약조건 추가
            genreView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    
    private func addActivityItem(icon: String, text: String, time: String) {
        let activityItemView = UIView()
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        iconImageView.contentMode = .scaleAspectFit
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1)
        
        let contentStackView = UIStackView(arrangedSubviews: [textLabel, timeLabel])
        contentStackView.axis = .vertical
        contentStackView.spacing = 2
        
        activityItemView.addSubview(iconImageView)
        activityItemView.addSubview(contentStackView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: activityItemView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: activityItemView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            contentStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: activityItemView.trailingAnchor, constant: -20),
            contentStackView.centerYAnchor.constraint(equalTo: activityItemView.centerYAnchor)
        ])
        
        activityContainerView.addSubview(activityItemView)
        
        activityItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityItemView.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor),
            activityItemView.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor),
            activityItemView.topAnchor.constraint(equalTo: activityItemView.superview!.subviews.last == activityItemView ? activityTitleLabel.bottomAnchor : activityItemView.superview!.subviews[activityItemView.superview!.subviews.firstIndex(of: activityItemView)! - 1].bottomAnchor, constant: 12),
            activityItemView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - 레이아웃 메서드 (변경 없음)
    private func layoutUI() {
        genreContainerView.translatesAutoresizingMaskIntoConstraints = false
        genreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        genreStackView.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.translatesAutoresizingMaskIntoConstraints = false
        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 장르 컨테이너
            genreContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            genreContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genreContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 장르 타이틀
            genreTitleLabel.topAnchor.constraint(equalTo: genreContainerView.topAnchor),
            genreTitleLabel.leadingAnchor.constraint(equalTo: genreContainerView.leadingAnchor),
            genreTitleLabel.trailingAnchor.constraint(equalTo: genreContainerView.trailingAnchor),
            
            // 장르 스택뷰
            genreStackView.topAnchor.constraint(equalTo: genreTitleLabel.bottomAnchor, constant: 12),
            genreStackView.leadingAnchor.constraint(equalTo: genreContainerView.leadingAnchor),
            genreStackView.trailingAnchor.constraint(equalTo: genreContainerView.trailingAnchor),
            genreStackView.bottomAnchor.constraint(equalTo: genreContainerView.bottomAnchor),
            
            // 활동 컨테이너
            activityContainerView.topAnchor.constraint(equalTo: genreContainerView.bottomAnchor, constant: 32),
            activityContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 활동 타이틀
            activityTitleLabel.topAnchor.constraint(equalTo: activityContainerView.topAnchor),
            activityTitleLabel.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 20),
            activityTitleLabel.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - 액션 메서드
    @objc private func editGenreTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "장르 편집", message: "선호하는 음악 장르를 입력하세요", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.genres[sender.tag]
            textField.placeholder = "장르 입력"
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let saveAction = UIAlertAction(title: "저장", style: .default) { _ in
            if let textField = alert.textFields?.first, let newGenre = textField.text, !newGenre.isEmpty {
                self.genres[sender.tag] = newGenre
                
                // 장르 업데이트 및 UserDefaults에 저장
                self.setupGenres()
                UserDefaultsManager.shared.saveGenres(self.genres)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - 공개 메서드
    func updateGenres(_ genres: [String]) {
        self.genres = genres
        setupGenres()
    }
}

#Preview {
    ProfileContentViewController()
}

