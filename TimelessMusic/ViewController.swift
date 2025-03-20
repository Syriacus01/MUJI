//
//  ViewController.swift
//  TimelessMusic
//
//  Created by Example on 2025/03/19.
//

import UIKit
import MusicKit
import MediaPlayer

/// Apple Music 재생을 위한 싱글톤 Player
class MusicPlayerManager {
    static let shared = MusicPlayerManager()
    private init() {}
    
    let player = ApplicationMusicPlayer.shared
}

/// Notification.Name 확장: nowPlayingItem이 바뀌면 통지
extension Notification.Name {
    static let myNowPlayingItemDidChange = Notification.Name("myNowPlayingItemDidChange")
}

/// 메인 ViewController: Apple Music 재생 & 앨범 커버 반투명 배경 + 슬라이더 UI
class ViewController: UIViewController {
    
    // MARK: - MusicKit 관련 속성
    
    /// 현재 재생할 곡 정보
    private var currentSong: Song?
    
    /// 현재 재생 여부
    private var isPlaying = false
    
    // MARK: - UI 요소
    
    /// 앨범커버 이미지를 배경으로 크게 표시하기 위한 ImageView (배경)
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 배경 위에 얹힐 블러 뷰
    private let backgroundBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    /// 중앙에 표시할 앨범커버
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// 곡 제목 라벨
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 아티스트명 라벨
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 재생/일시정지 버튼
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 다음 곡 버튼
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 이전 곡 버튼
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 검색창 (실제 검색은 새 모달 화면에서 진행)
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Apple Music에서 곡 검색"
        searchBar.backgroundImage = UIImage() // 기본 배경 제거
        searchBar.backgroundColor = .clear    // 투명 처리
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    // MARK: - 새로 추가할 UI (슬라이더 2종)
    
    /// (1) 재생 위치(Seek) 슬라이더
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        // 원하는 틴트 색상
        slider.minimumTrackTintColor = .systemGreen
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    /// (2) 볼륨 조절 슬라이더 (MPVolumeView 사용)
    private let volumeView: MPVolumeView = {
        let vv = MPVolumeView()
        // AirPlay 버튼을 숨기고 싶다면 아래 옵션
        // vv.showsRouteButton = false
        vv.translatesAutoresizingMaskIntoConstraints = false
        return vv
    }()
    
    /// 재생 위치 갱신용 타이머
    private var updateTimer: Timer?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (1) 배경 색 (블러 없을 경우 대비)
        view.backgroundColor = .white
        
        // (2) 앨범커버 배경 이미지 뷰 추가
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (3) 블러 뷰 추가
        view.addSubview(backgroundBlurView)
        NSLayoutConstraint.activate([
            backgroundBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (4) 앨범커버, 라벨, 버튼 등 UI 요소 배치
        setupMainUI()
        
        // (5) 검색창을 간단히 추가 (모달 트리거만)
        setupSearchBar()
        
        // (6) 슬라이더(재생 위치, 볼륨) UI 배치
        setupSliders()
        
        // (7) nowPlayingItem 변경 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemChanged),
            name: .myNowPlayingItemDidChange,
            object: MusicPlayerManager.shared.player
        )
        
        // (8) 초기 아트워크 업데이트 (이미 재생 중인 곡이 있을 수도 있으므로)
        updateArtwork()
        preloadSampleSong()
        
        // (9) 재생 위치 갱신 타이머 시작
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(updateProgressSlider),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
    }
    
    // MARK: - UI 배치 함수
    
    /// 앨범커버, 곡정보, 재생 버튼 배치
    private func setupMainUI() {
        // 1) 앨범커버
        view.addSubview(artworkImageView)
        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            artworkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 300),
            artworkImageView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // 2) 라벨(곡제목, 아티스트)
        view.addSubview(songTitleLabel)
        view.addSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            songTitleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 10),
            songTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            artistNameLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 4),
            artistNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 3) 재생/다음/이전 버튼
        view.addSubview(playPauseButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        
        // 버튼 액션
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        // 버튼 레이아웃
        let playPauseSize: CGFloat = 70
        let spacing: CGFloat = 30
        NSLayoutConstraint.activate([
            // play/pause
            playPauseButton.widthAnchor.constraint(equalToConstant: playPauseSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: playPauseSize),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // previous
            previousButton.widthAnchor.constraint(equalToConstant: playPauseSize * 0.8),
            previousButton.heightAnchor.constraint(equalToConstant: playPauseSize * 0.8),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -spacing),
            
            // next
            nextButton.widthAnchor.constraint(equalToConstant: playPauseSize * 0.8),
            nextButton.heightAnchor.constraint(equalToConstant: playPauseSize * 0.8),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: spacing)
        ])
        
        // 버튼 색상 (흰색 아이콘)
        [playPauseButton, nextButton, previousButton].forEach {
            $0.tintColor = .white
        }
    }
    
    /// 검색창(트리거)만 추가: 실제 검색은 모달에서 처리
    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 아래쪽에 배치
            searchBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    /// (새로 추가) 재생 위치 슬라이더 + 볼륨 뷰 배치
    private func setupSliders() {
        // 재생 위치 슬라이더
        view.addSubview(progressSlider)
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        
        // 볼륨 뷰
        view.addSubview(volumeView)
        
    NSLayoutConstraint.activate([
        // 재생 위치 슬라이더는 아티스트명 라벨 아래쪽에 배치
        progressSlider.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 20),
        progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
        progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

        // 플레이/일시정지 버튼을 재생 위치 슬라이더 아래쪽에 배치
        playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 20),
        playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        // 볼륨 뷰를 플레이/일시정지 버튼 아래쪽에 배치
        volumeView.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 20),
        volumeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        volumeView.widthAnchor.constraint(equalToConstant: 300),
        volumeView.heightAnchor.constraint(equalToConstant: 40)
    ])
    }
    
    // MARK: - MusicKit: 재생/아트워크 업데이트
    
    /// 현재 곡 아트워크 업데이트
    private func updateArtwork() {
        guard let song = currentSong,
              let artworkURL = song.artwork?.url(width: 1000, height: 1000) else { return }
        
        // 1) 비동기로 이미지 다운로드
        URLSession.shared.dataTask(with: artworkURL) { [weak self] data, _, error in
            if let error = error {
                print("아트워크 다운로드 에러: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("이미지 변환 실패")
                return
            }
            DispatchQueue.main.async {
                // 중앙 앨범커버
                self?.artworkImageView.image = image
                // 배경 앨범커버
                self?.backgroundImageView.image = image
            }
        }.resume()
        
        // 2) 곡제목, 아티스트명 라벨 업데이트 (페이드 애니메이션)
        UIView.transition(with: songTitleLabel,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.songTitleLabel.text = song.title
        }, completion: nil)
        UIView.transition(with: artistNameLabel,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.artistNameLabel.text = song.artistName
        }, completion: nil)
    }
    
    /// MusicKit Player의 nowPlayingItem이 변경되었을 때
    @objc private func nowPlayingItemChanged() {
        updateArtwork()
    }
    
    // MARK: - 재생/일시정지/다음/이전 버튼 액션
    
    /// 재생/일시정지 버튼 액션
    @objc private func playPauseButtonTapped() {
        Task {
            do {
                // 1) MusicKit 권한 요청
                let status = await MusicAuthorization.request()
                guard status == .authorized else {
                    print("Music 권한 거부됨")
                    return
                }
                
                let player = MusicPlayerManager.shared.player
                
                // 이미 재생 중이면 일시정지
                if isPlaying {
                    player.pause()
                    playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    isPlaying.toggle()
                    return
                }
                
                // 큐가 비어있을 경우, 기본 샘플 노래 또는 검색창 텍스트로 노래를 가져옴
                if player.queue.entries.isEmpty {
                    if let song = currentSong {
                        player.queue = [song]
                    } else {
                        // 검색창에 텍스트가 있으면 그 텍스트로, 없으면 기본 샘플 노래 검색
                        let searchTerm = searchBar.text?.isEmpty == false
                            ? searchBar.text!
                            : "Anxiety - 도이치"
                        let searchRequest = MusicCatalogSearchRequest(
                            term: searchTerm,
                            types: [Song.self, Album.self, Artist.self, Playlist.self]
                        )
                        let response = try await searchRequest.response()
                        guard let firstSong = response.songs.first else {
                            print("노래를 찾을 수 없습니다.")
                            return
                        }
                        currentSong = firstSong
                        player.queue = [firstSong]
                    }
                }
                
                try await player.play()
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                updateArtwork()
                isPlaying.toggle()
                
            } catch {
                print("재생 에러: \(error)")
            }
        }
    }
    
    /// 다음 곡 버튼
    @objc private func nextButtonTapped() {
        Task {
            do {
                try await MusicPlayerManager.shared.player.skipToNextEntry()
            } catch {
                print("다음 곡으로 건너뛰기 실패: \(error)")
            }
        }
    }
    
    /// 이전 곡 버튼
    @objc private func previousButtonTapped() {
        Task {
            do {
                try await MusicPlayerManager.shared.player.skipToPreviousEntry()
            } catch {
                print("이전 곡으로 건너뛰기 실패: \(error)")
            }
        }
    }
    
    // MARK: - 샘플 곡 미리 불러오기
    
    /// 앱 실행 후 첫 화면에 표시될 샘플 곡(검색)
    private func preloadSampleSong() {
        Task {
            // 이미 currentSong이 있으면 패스
            if currentSong != nil { return }
            do {
                let searchTerm = "Anxiety - 도이치"
                let searchRequest = MusicCatalogSearchRequest(term: searchTerm,
                                                              types: [Song.self, Album.self, Artist.self, Playlist.self])
                let response = try await searchRequest.response()
                guard let firstSong = response.songs.first else {
                    print("샘플 노래를 찾을 수 없습니다.")
                    return
                }
                currentSong = firstSong
                updateArtwork()
            } catch {
                print("샘플 노래 불러오기 실패: \(error)")
            }
        }
    }
    
    // MARK: - 재생 위치 슬라이더 업데이트 메서드
    @objc private func updateProgressSlider() {
        let player = MusicPlayerManager.shared.player
        
        // 현재 재생 중인 곡의 정보를 currentSong에서 얻음
        guard let currentSong = currentSong,
              let totalTime = currentSong.duration else { return }

        let currentTime = player.playbackTime
        if totalTime > 0 {
            progressSlider.value = Float(currentTime / totalTime)
        }
    }

    // 사용자가 재생 위치 슬라이더를 움직였을 때 처리
    @objc private func progressSliderValueChanged(_ sender: UISlider) {
        let player = MusicPlayerManager.shared.player
        
        guard let currentSong = currentSong,
              let totalTime = currentSong.duration else { return }
        
        let newTime = Double(sender.value) * totalTime
        player.playbackTime = newTime
    }
    }

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    /// 검색창을 누르면 모달(또는 iOS 15+ 시트)로 SearchViewController 띄움
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let searchVC = SearchViewController()
        
        // iOS 15+에서는 시트로, iOS 14 이하는 .fullScreen 모달로 활용 가능
        if let sheet = searchVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        } else {
            searchVC.modalPresentationStyle = .fullScreen
        }
        present(searchVC, animated: true)
        return false
    }
}

