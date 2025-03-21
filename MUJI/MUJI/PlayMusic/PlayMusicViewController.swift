import UIKit
import MusicKit
import MediaPlayer
import AVKit

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
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 아티스트명 라벨
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21, weight: .regular)
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
    
    /// 이전 곡 버튼
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
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
    
    /// 검색창 (실제 검색은 새 모달 화면(SearchViewController)에서 진행)
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Apple Music에서 곡 검색"
        searchBar.backgroundImage = UIImage() // 기본 배경 제거
        searchBar.backgroundColor = .clear    // 투명 처리
        
        // (1) 검색창 그림자 추가
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        searchBar.layer.shadowOpacity = 0.1
        searchBar.layer.shadowRadius = 3
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    // MARK: - 슬라이더 및 볼륨 뷰
    
    /// 재생 위치(Seek) 슬라이더
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        // (2) 슬라이더 Thumb(동그란 버튼) 제거
        slider.setThumbImage(UIImage(), for: .normal)
        
        return slider
    }()
    
    /// 볼륨 조절 슬라이더 (MPVolumeView 사용)
    private let volumeView: MPVolumeView = {
        let vv = MPVolumeView()
        vv.translatesAutoresizingMaskIntoConstraints = false
        return vv
    }()
    
    /// 재생 위치 갱신용 타이머
    private var updateTimer: Timer?
    
    // MARK: - Life Cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 기존에 설정된 마스크 제거 (있을 경우)
        artworkImageView.layer.mask = nil
        
        // 그라데이션 마스크 생성
        let gradientMask = CAGradientLayer()
        gradientMask.frame = artworkImageView.bounds
        if #available(iOS 12.0, *) {
            gradientMask.type = .radial
        }
        // 마지막 색상을 완전히 투명하지 않게 설정하여 경계가 부드럽게 처리됨
        gradientMask.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientMask.locations = [0.0, 0.85, 1.0]
        artworkImageView.layer.mask = gradientMask
    }
    
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
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // (3) 블러 뷰 추가
        view.addSubview(backgroundBlurView)
        NSLayoutConstraint.activate([
            backgroundBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // (4) 앨범커버, 라벨, 버튼 등 UI 요소 배치
        setupMainUI()
        
        // (5) 검색창 추가 (모달 트리거 역할)
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
        
        // 새 알림: SongDidChange
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemChanged),
            name: Notification.Name("SongDidChange"),
            object: nil
        )
        
        // (8) 초기 아트워크 업데이트 (재생 중인 곡이 있을 수도 있으므로)
        updateArtwork()
        
        // (9) 탭 바 블러 효과 설정
        setupTabBarBlur()
        
        // (10) 재생 위치 갱신 타이머 시작
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(updateProgressSlider),
                                           userInfo: nil,
                                           repeats: true)
        
        // (11) 앱 최초 실행 시 “Jaded(19)” 자동 로드 (자동재생 X, UI만 표시)
        autoLoadSong()
        
        // (12) 볼륨 슬라이더의 Thumb 제거 (MPVolumeView 내부 접근)
        DispatchQueue.main.async {
            // Hide the AirPlay route button for iOS 13+ by hiding UIButton subviews
            for subview in self.volumeView.subviews {
                if let button = subview as? UIButton {
                    button.isHidden = true
                }
            }
            if let volumeSlider = self.volumeView.subviews.compactMap({ $0 as? UISlider }).first {
                volumeSlider.setThumbImage(UIImage(), for: .normal)
            }
        }
    }
    
    /// 앱 최초 실행 시 Jaded(19) 곡 정보를 불러오는 함수
    private func autoLoadSong() {
        Task {
            do {
                let status = await MusicAuthorization.request()
                guard status == .authorized else {
                    print("Music 권한 거부됨")
                    return
                }
                
                let player = MusicPlayerManager.shared.player
                // 큐가 비어있다면 곡 검색 후 UI에 표시
                if player.queue.entries.isEmpty {
                    let searchTerm = "I CAN DO IT WITH A BROKEN HEART! - Taylor Swift"
                    let searchRequest = MusicCatalogSearchRequest(
                        term: searchTerm,
                        types: [Song.self, Album.self, Artist.self, Playlist.self]
                    )
                    let response = try await searchRequest.response()
                    
                    guard let firstSong = response.songs.first else {
                        print("노래를 찾을 수 없습니다.")
                        return
                    }
                    
                    if let rubySong = response.songs.first(where: { $0.albumTitle == "Ruby" }) {
                        currentSong = rubySong
                        player.queue = [rubySong]
                        print("Ruby 앨범 버전 선택됨: \(rubySong.title)")
                    } else {
                        currentSong = firstSong
                        player.queue = [firstSong]
                    }
                    
                    // 자동 재생을 원한다면 다음 두 줄을 주석 해제
                    // try await player.play()
                    // isPlaying = true
                    
                    // UI 업데이트 (앨범 커버, 라벨 등)
                    DispatchQueue.main.async {
                        self.updateArtwork()
                    }
                }
            } catch {
                print("재생 에러: \(error)")
            }
        }
    }
    
    /// 탭 바에 블러 효과를 적용하는 함수 (투명도 조절 가능)
    private func setupTabBarBlur() {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tabBar.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let desiredAlpha: CGFloat = 0.5
        blurView.alpha = desiredAlpha
        tabBar.insertSubview(blurView, at: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
    }
    
    // MARK: - UI 배치 함수
    
    /// 앨범커버, 곡정보, 재생 버튼 등을 배치하는 함수
    private func setupMainUI() {
        // 1) 앨범커버 배치
        view.addSubview(artworkImageView)
        NSLayoutConstraint.activate([
            artworkImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            artworkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkImageView.widthAnchor.constraint(equalToConstant: 400),
            artworkImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        // 2) 곡 제목 및 아티스트 라벨 배치
        view.addSubview(songTitleLabel)
        view.addSubview(artistNameLabel)
        NSLayoutConstraint.activate([
            songTitleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 10),
            songTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistNameLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 4),
            artistNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 3) 재생/일시정지, 다음, 이전 버튼 배치
        view.addSubview(playPauseButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        
        // 버튼 액션 연결
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        // 버튼 레이아웃: 재생/일시정지 버튼을 기준으로 이전, 다음 버튼 배치
        // MARK: - UI Layout Constants
        /// 재생/일시정지 버튼의 크기 (기본값: 70)
        let playPauseButtonSize: CGFloat = 70
        /// 이전/다음 버튼은 재생/일시정지 버튼 크기의 몇 배로 표시할지 결정 (기본값: 0.8)
        let controlButtonSizeRatio: CGFloat = 0.8
        /// 버튼들 사이의 간격 (기본값: 30)
        let buttonSpacing: CGFloat = 30
        
        NSLayoutConstraint.activate([
            // 재생/일시정지 버튼: 크기 지정 및 가로 중앙 배치
            playPauseButton.widthAnchor.constraint(equalToConstant: playPauseButtonSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: playPauseButtonSize),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 이전 버튼: 재생 버튼의 왼쪽에 배치, 크기는 재생 버튼의 controlButtonSizeRatio 배율
            previousButton.widthAnchor.constraint(equalToConstant: playPauseButtonSize * controlButtonSizeRatio),
            previousButton.heightAnchor.constraint(equalToConstant: playPauseButtonSize * controlButtonSizeRatio),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -buttonSpacing),
            
            // 다음 버튼: 재생 버튼의 오른쪽에 배치, 크기는 재생 버튼의 controlButtonSizeRatio 배율
            nextButton.widthAnchor.constraint(equalToConstant: playPauseButtonSize * controlButtonSizeRatio),
            nextButton.heightAnchor.constraint(equalToConstant: playPauseButtonSize * controlButtonSizeRatio),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: buttonSpacing)
        ])
        
        // 버튼 색상: 흰색 아이콘
        [playPauseButton, nextButton, previousButton].forEach {
            $0.tintColor = .white
        }
    }
    
    /// 검색창을 배치하는 함수 (실제 검색은 모달 화면에서 진행)
    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    /// 슬라이더(재생 위치 슬라이더, 볼륨 조절 슬라이더) 배치 함수
    private func setupSliders() {
        // 재생 위치 슬라이더 배치
        view.addSubview(progressSlider)
        progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        
        // 볼륨 뷰 배치
        view.addSubview(volumeView)
        
        NSLayoutConstraint.activate([
            // 재생 위치 슬라이더: 아티스트 라벨 아래에 배치, 좌우 40 포인트
            progressSlider.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 20),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // 재생/일시정지 버튼: 재생 위치 슬라이더 아래에 배치, 가로 중앙
            playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 20),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 볼륨 뷰: 재생/일시정지 버튼 아래에 배치, 재생 슬라이더와 동일한 길이
            volumeView.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 20),
            volumeView.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            volumeView.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            volumeView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - MusicKit: 재생/아트워크 업데이트
    
    /// 현재 곡의 아트워크와 곡 정보를 업데이트하는 함수
    private func updateArtwork() {
        guard let song = currentSong,
              let artworkURL = song.artwork?.url(width: 2000, height: 2000) else { return }
        
        // 비동기로 이미지 다운로드
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
                // 중앙 앨범커버 업데이트
                self?.artworkImageView.image = image
                // 배경 이미지 업데이트
                self?.backgroundImageView.image = image
            }
        }.resume()
        
        // 곡 제목, 아티스트 라벨 업데이트 (페이드 애니메이션)
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
    
    /// MusicKit Player의 nowPlayingItem 변경 시 호출되는 함수
    @objc private func nowPlayingItemChanged() {
        // Issue 3: 모달에서 노래 선택 시 MusicPlayer의 큐 첫번째 항목에서 Song 객체를 업데이트하기 위해 Song ID를 가져온 후, 해당 Song을 MusicCatalogResourceRequest를 통해 불러옴
        guard let firstEntry = MusicPlayerManager.shared.player.queue.entries.first,
              let songID = firstEntry.item?.id else {
            updateArtwork()
            return
        }
        
        Task {
            do {
                let request = MusicCatalogResourceRequest<Song>(matching: \SongFilter.id, equalTo: songID)
                let response = try await request.response()
                if let song = response.items.first {
                    self.currentSong = song
                    DispatchQueue.main.async {
                        self.updateArtwork()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.updateArtwork()
                    }
                }
            } catch {
                print("Song update error: \(error)")
                DispatchQueue.main.async {
                    self.updateArtwork()
                }
            }
        }
    }
    // MARK: - 재생/일시정지/다음/이전 버튼 액션
    
    /// 재생/일시정지 버튼 액션
    @objc private func playPauseButtonTapped() {
        Task {
            do {
                // MusicKit 권한 요청
                let status = await MusicAuthorization.request()
                guard status == .authorized else {
                    print("Music 권한 거부됨")
                    return
                }
                
                let player = MusicPlayerManager.shared.player
                
                // 재생 중이면 일시정지, 아니면 재생
                if isPlaying {
                    player.pause()
                    playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    isPlaying.toggle()
                    return
                }
                
                // 큐가 비어있을 경우 기본 샘플 노래 또는 검색창 텍스트로 노래를 가져옴
                if player.queue.entries.isEmpty {
                    if let song = currentSong {
                        player.queue = [song]
                    } else {
                        // 기본 검색어: 사용자가 입력하지 않을 경우 기본적으로 를 재생하도록 설정
                        let searchTerm = searchBar.text?.isEmpty == false ? searchBar.text! : "Love Hangover - 제니 & 도미닉 파이크"
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
    
    /// 다음 곡 버튼 액션
    @objc private func nextButtonTapped() {
        Task {
            do {
                try await MusicPlayerManager.shared.player.skipToNextEntry()
            } catch {
                print("다음 곡으로 건너뛰기 실패: \(error)")
            }
        }
    }
    
    /// 이전 곡 버튼 액션
    @objc private func previousButtonTapped() {
        Task {
            do {
                try await MusicPlayerManager.shared.player.skipToPreviousEntry()
            } catch {
                print("이전 곡으로 건너뛰기 실패: \(error)")
            }
        }
    }
    
    // MARK: - 재생 위치 슬라이더 업데이트
    
    /// 재생 위치 슬라이더를 업데이트하는 함수
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
    
    /// 사용자가 재생 위치 슬라이더를 조작할 때 호출되는 함수
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
    /// 검색창을 터치하면 SearchViewController 모달(또는 iOS 15+ 시트)로 전환
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let searchVC = SearchViewController()
        
        // Issue 2: 모달의 배경을 투명하게 처리하여 뒷배경이 더 보이도록 함
        searchVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        if let sheet = searchVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        } else {
            searchVC.modalPresentationStyle = .overFullScreen
        }
        present(searchVC, animated: true)
        return false
    }
}
