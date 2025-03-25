import UIKit
import MusicKit

private struct UIConstants {
    static let searchBarPlaceholder = "검색"
    static let tableViewCellIdentifier = "cell"
    static let blurStyle: UIBlurEffect.Style = .systemMaterial
}

private struct Constants {
    static let unsupportedSelectionMessage = "선택한 항목은 재생할 수 없습니다."
    static let songDidChangeNotificationName = "SongDidChange"
}

// MARK: - MusicSearchResult Enum
// MusicKit 검색 결과를 나타내는 열거형
enum MusicSearchResult {
    case song(Song)          // 노래 결과
    case album(Album)        // 앨범 결과
    case artist(Artist)      // 아티스트 결과
    case playlist(Playlist)  // 재생목록 결과
    
    // 검색 결과에 대한 표시 텍스트를 반환
    var displayText: String {
        switch self {
        case .song(let song):
            return "\(song.title) - \(song.artistName)" // 노래 제목과 아티스트 이름
        case .album(let album):
            return "\(album.title) - 앨범" // 앨범 제목
        case .artist(let artist):
            return artist.name // 아티스트 이름
        case .playlist(let playlist):
            return "\(playlist.name) - 재생목록" // 재생목록 이름
        }
    }
}

// MARK: - SearchViewController
// SearchViewController는 MusicKit을 사용한 검색 기능을 담당하는 뷰 컨트롤러입니다.
class SearchViewController: UIViewController {
    
    // MARK: - UI 컴포넌트
    // 검색창: 사용자로부터 검색어를 입력받습니다.
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = UIConstants.searchBarPlaceholder
        sb.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        sb.isTranslucent = true
        sb.backgroundColor = UIColor.clear
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // 검색 결과를 표시할 테이블 뷰
    private let resultsTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.clear
        tv.isOpaque = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // 검색 결과 데이터 배열
    private var searchResults: [MusicSearchResult] = []
    
    // 전체 화면에 적용될 블러 효과 뷰
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: UIConstants.blurStyle)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 생명주기 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (1) 배경을 투명 또는 반투명으로 설정 (overFullScreen 모달의 경우)
        view.backgroundColor = .clear
        
        // (2) 전체 화면 블러 효과 추가
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (3) 검색창과 검색 결과 테이블 뷰를 메인 뷰에 추가
        view.addSubview(searchBar)
        view.addSubview(resultsTableView)
        
        // (4) 오토레이아웃 설정
        NSLayoutConstraint.activate([
            // 검색창: 안전 영역 상단에 배치
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 테이블 뷰: 검색창 아래 전체 영역을 차지
            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (5) 검색창 및 테이블 뷰의 델리게이트와 데이터소스 설정
        searchBar.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: UIConstants.tableViewCellIdentifier)
        
        // (6) 화면 탭 시 키보드 숨김
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // (7) iOS 15 이상에서 시트 프레젠테이션 설정
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    // MARK: - 사용자 액션 메서드
    // 키보드를 숨기는 메서드
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate 구현
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색창에 입력된 텍스트가 있는지 확인
        guard let term = searchBar.text, !term.isEmpty else { return }
        
        Task {
            do {
                // MusicKit 검색 요청 생성 및 응답 처리
                let request = MusicCatalogSearchRequest(term: term, types: [Song.self, Album.self, Artist.self, Playlist.self])
                let response = try await request.response()
                
                // 검색 결과 배열 생성
                var results: [MusicSearchResult] = []
                results.append(contentsOf: response.songs.map { .song($0) })
                results.append(contentsOf: response.albums.map { .album($0) })
                results.append(contentsOf: response.artists.map { .artist($0) })
                results.append(contentsOf: response.playlists.map { .playlist($0) })
                
                self.searchResults = results
                // 메인 스레드에서 테이블 뷰 업데이트
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            } catch {
                print("검색 요청 처리 중 에러 발생: \(error)")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource 구현
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // 테이블 뷰의 행 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // 각 행에 대한 셀 생성 및 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.tableViewCellIdentifier, for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.displayText
        return cell
    }
    
    // 셀 선택 시 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        switch selectedResult {
        case .song(let song):
            // 선택된 노래 재생
            playSong(song)
        default:
            print(Constants.unsupportedSelectionMessage)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // 모달 화면 닫기 (옵션)
        dismiss(animated: true)
    }
    
    // 선택된 노래를 재생하는 메서드
    private func playSong(_ song: Song) {
        Task {
            do {
                let player = ApplicationMusicPlayer.shared
                player.queue = [song]
                try await player.play()
                // 노래 변경 시 앨범 커버 업데이트를 위한 알림 전송
                NotificationCenter.default.post(name: Notification.Name(Constants.songDidChangeNotificationName), object: song)
            } catch {
                print("노래 재생 중 에러 발생: \(error)")
            }
        }
    }
}
