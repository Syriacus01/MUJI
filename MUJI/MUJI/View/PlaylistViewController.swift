//
//  PlaylistViewController 2.swift
//  MUJI
//
//  Created by 원대한 on 3/19/25.
//


import UIKit
import SwiftUI

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - 프로퍼티
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    
    // 노래 데이터 - 빈 배열로 초기화하고 나중에 로드
    private var songs: [UserSong] = []
    
    // MARK: - 라이프사이클 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadSongData()
        setupUI()
        layoutUI()
    }
    
    // MARK: - 데이터 로드 메서드
    private func loadSongData() {
        // UserDefaults에서 노래 데이터 로드
        if let loadedSongs = UserDefaultsManager.shared.getSongs() {
            songs = loadedSongs
        } else {
            // 기본 데이터 설정 (UserDefaults에 데이터가 없는 경우)
            let defaultSongs: [UserSong] = [
                UserSong(id: "1", title: "봄날", artist: "BTS", emotion: "행복"),
                UserSong(id: "2", title: "눈의 꽃", artist: "박효신", emotion: "평온"),
                UserSong(id: "3", title: "FAKE LOVE", artist: "BTS", emotion: "슬픔"),
                UserSong(id: "4", title: "좋은 날", artist: "아이유", emotion: "행복"),
                UserSong(id: "5", title: "에잇", artist: "아이유", emotion: "슬픔")
            ]
            songs = defaultSongs
            
            // 기본 데이터를 JSON으로 변환하여 저장
            do {
                let jsonData = try JSONEncoder().encode(defaultSongs)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaultsManager.shared.saveSongs(jsonString)
                }
            } catch {
                print("노래 데이터 인코딩 오류: \(error)")
            }
        }
    }
    
    // 외부에서 JSON 문자열로 노래 데이터를 설정할 수 있는 메서드
    func updateSongData(jsonString: String) {
        if let parsedSongs = DataManager.shared.parseSongs(from: jsonString) {
            songs = parsedSongs
            UserDefaultsManager.shared.saveSongs(jsonString)
            
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - 셋업 메서드
    private func setup() {
        view.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 0.95)
        title = "플레이리스트"
    }
    
    private func setupUI() {
        // 타이틀 라벨
        titleLabel.text = "플레이리스트"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        
        // 테이블뷰 설정
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "SongCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        // 뷰 추가
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    // MARK: - 레이아웃 메서드
    private func layoutUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 타이틀 라벨
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 테이블뷰
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        cell.configure(title: song.title, artist: song.artist, emotion: song.emotion)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - 추가 기능: 새 노래 추가
    func addNewSong(title: String, artist: String, emotion: String) {
        // 새 ID 생성 (현재 가장 큰 ID + 1)
        let nextId = (songs.compactMap { Int($0.id) }.max() ?? 0) + 1
        
        // 새 노래 생성
        let newSong = UserSong(id: String(nextId), title: title, artist: artist, emotion: emotion)
        songs.append(newSong)
        
        // JSON으로 변환하여 저장
        do {
            let jsonData = try JSONEncoder().encode(songs)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                UserDefaultsManager.shared.saveSongs(jsonString)
            }
        } catch {
            print("노래 데이터 인코딩 오류: \(error)")
        }
        
        // 테이블뷰 갱신
        tableView.reloadData()
    }
}
