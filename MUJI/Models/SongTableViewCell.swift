//
//  SongTableViewCell.swift
//  MUJI
//
//  Created by 원대한 on 3/19/25.
//


import UIKit

class SongTableViewCell: UITableViewCell {
    // MARK: - 프로퍼티
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let emotionLabel = UILabel()
    
    // MARK: - 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 셋업 메서드
    private func setupUI() {
        // 셀 설정
        backgroundColor = .clear
        selectionStyle = .none
        
        // 컨테이너 뷰
        containerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 12
        
        // 타이틀 라벨
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        
        // 아티스트 라벨
        artistLabel.font = UIFont.systemFont(ofSize: 14)
        artistLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        
        // 감정 라벨
        emotionLabel.font = UIFont.systemFont(ofSize: 14)
        emotionLabel.textAlignment = .center
        emotionLabel.textColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        emotionLabel.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1)
        emotionLabel.layer.cornerRadius = 12
        emotionLabel.clipsToBounds = true
        
        // 뷰 추가
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)
        containerView.addSubview(emotionLabel)
    }
    
    // MARK: - 레이아웃 메서드
    private func layoutUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 컨테이너 뷰
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // 타이틀 라벨
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // 아티스트 라벨
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            artistLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // 감정 라벨
            emotionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            emotionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emotionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            emotionLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - 구성 메서드
    func configure(title: String, artist: String, emotion: String) {
        titleLabel.text = title
        artistLabel.text = artist
        emotionLabel.text = emotion
        
        // 감정에 따라 색상 설정
        var backgroundColor: UIColor
        
        switch emotion {
        case "행복":
            backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.93, alpha: 1)
            emotionLabel.textColor = UIColor(red: 1, green: 0.6, blue: 0.4, alpha: 1)
        case "슬픔":
            backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 1, alpha: 1)
            emotionLabel.textColor = UIColor(red: 0.4, green: 0.6, blue: 1, alpha: 1)
        case "평온":
            backgroundColor = UIColor(red: 0.93, green: 1, blue: 0.95, alpha: 1)
            emotionLabel.textColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1)
        default:
            backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 255/255, alpha: 1)
            emotionLabel.textColor = UIColor(red: 88/255, green: 126/255, blue: 255/255, alpha: 1)
        }
        
        emotionLabel.backgroundColor = backgroundColor
    }
}