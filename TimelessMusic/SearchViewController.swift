import UIKit
import MusicKit

enum MusicSearchResult {
    case song(Song)
    case album(Album)
    case artist(Artist)
    case playlist(Playlist)
    
    var displayText: String {
        switch self {
        case .song(let song):
            return "\(song.title) - \(song.artistName)"
        case .album(let album):
            return "\(album.title) - Album"
        case .artist(let artist):
            return artist.name
        case .playlist(let playlist):
            return "\(playlist.name) - Playlist"
        }
    }
}

class SearchViewController: UIViewController {
    
    // 검색창
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "검색"
        sb.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        sb.isTranslucent = true
        sb.backgroundColor = UIColor.clear
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // 검색 결과 테이블
    private let resultsTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.clear
        tv.isOpaque = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // 검색 결과 데이터
    private var searchResults: [MusicSearchResult] = []
    
    // 블러 배경
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (1) 배경을 투명/반투명으로 (overFullScreen일 경우)
        view.backgroundColor = .clear
        
        // (2) 전체화면 블러
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (3) 검색창 + 테이블 뷰 추가
        view.addSubview(searchBar)
        view.addSubview(resultsTableView)
        
        // (4) 오토레이아웃
        NSLayoutConstraint.activate([
            // 검색창: safeArea 상단에
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 테이블 뷰: 검색창 아래 전체
            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // (5) 델리게이트/데이터소스
        searchBar.delegate = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // (6) 탭하면 키보드 숨기기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // iOS 15+ Sheet Presentation
        if let sheet = sheetPresentationController {
            sheet.detents = [
                .medium(),
                .large()
            ]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text, !term.isEmpty else { return }
        
        Task {
            do {
                // MusicKit 검색
                let request = MusicCatalogSearchRequest(term: term, types: [Song.self, Album.self, Artist.self, Playlist.self])
                let response = try await request.response()
                
                var results: [MusicSearchResult] = []
                results.append(contentsOf: response.songs.map { .song($0) })
                results.append(contentsOf: response.albums.map { .album($0) })
                results.append(contentsOf: response.artists.map { .artist($0) })
                results.append(contentsOf: response.playlists.map { .playlist($0) })
                
                self.searchResults = results
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.displayText
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        switch selectedResult {
        case .song(let song):
            playSong(song)
        default:
            print("선택한 항목은 재생할 수 없습니다.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // 모달 닫기(옵션)
        dismiss(animated: true)
    }
    
    private func playSong(_ song: Song) {
        Task {
            do {
                let player = ApplicationMusicPlayer.shared
                player.queue = [song]
                try await player.play()
            } catch {
                print(error)
            }
        }
    }
}
