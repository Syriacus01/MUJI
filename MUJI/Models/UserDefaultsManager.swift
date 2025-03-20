import Foundation
import UIKit

// 프로필 정보 관리를 위한 UserDefaults 매니저
class UserDefaultsManager {
    // 싱글톤 패턴으로 구현
    static let shared = UserDefaultsManager()
    
    // UserDefaults 키 값
    private enum Keys {
        static let name = "profile_name"
        static let username = "profile_username"
        static let bio = "profile_bio"
        static let location = "profile_location"
        static let genres = "profile_genres"
        static let age = "profile_age"
        static let profileImage = "profile_image"
        
        // 추가된 키
        static let emotionStats = "emotion_stats"
        static let activityItems = "activity_items"
        static let songs = "playlist_songs"
        
        // 기본값 저장 키
        static let defaultName = "default_name"
        static let defaultUsername = "default_username"
        static let defaultBio = "default_bio"
        static let defaultLocation = "default_location"
        static let defaultGenres = "default_genres"
        static let defaultAge = "default_age"
    }
    
    // UserDefaults 인스턴스
    private let defaults = UserDefaults.standard
    
    // 초기 기본값
    private var initialDefaultName = "김도연"
    private var initialDefaultUsername = "@doyeon_kim"
    private var initialDefaultBio = "음악과 함께하는 일상 🎵"
    private var initialDefaultLocation = "서울, 대한민국"
    private var initialDefaultGenres = ["K-POP", "R&B", "팝"]
    private var initialDefaultAge = "20세"
    
    // 초기화 메서드
    private init() {
        // 앱 최초 실행 시 기본값 저장
        if !defaults.bool(forKey: "defaults_initialized") {
            saveDefaultName(initialDefaultName)
            saveDefaultUsername(initialDefaultUsername)
            saveDefaultBio(initialDefaultBio)
            saveDefaultLocation(initialDefaultLocation)
            saveDefaultGenres(initialDefaultGenres)
            saveDefaultAge(initialDefaultAge)
            
            defaults.set(true, forKey: "defaults_initialized")
        }
    }
    
    // MARK: - 이미지 저장 및 로드
    func saveProfileImage(_ image: UIImage?) {
        guard let image = image else {
            defaults.removeObject(forKey: Keys.profileImage)
            return
        }
        
        // 이미지를 데이터로 변환하여 저장
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            defaults.set(imageData, forKey: Keys.profileImage)
        }
    }
    
    func getProfileImage() -> UIImage? {
        guard let imageData = defaults.data(forKey: Keys.profileImage) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    // MARK: - 이름 관리
    func saveName(_ name: String) {
        defaults.set(name, forKey: Keys.name)
    }
    
    func getName() -> String {
        return defaults.string(forKey: Keys.name) ?? getDefaultName()
    }
    
    func saveDefaultName(_ name: String) {
        defaults.set(name, forKey: Keys.defaultName)
    }
    
    func getDefaultName() -> String {
        return defaults.string(forKey: Keys.defaultName) ?? initialDefaultName
    }
    
    // MARK: - 사용자명 관리
    func saveUsername(_ username: String) {
        defaults.set(username, forKey: Keys.username)
    }
    
    func getUsername() -> String {
        return defaults.string(forKey: Keys.username) ?? getDefaultUsername()
    }
    
    func saveDefaultUsername(_ username: String) {
        defaults.set(username, forKey: Keys.defaultUsername)
    }
    
    func getDefaultUsername() -> String {
        return defaults.string(forKey: Keys.defaultUsername) ?? initialDefaultUsername
    }
    
    // MARK: - 소개 관리
    func saveBio(_ bio: String) {
        defaults.set(bio, forKey: Keys.bio)
    }
    
    func getBio() -> String {
        return defaults.string(forKey: Keys.bio) ?? getDefaultBio()
    }
    
    func saveDefaultBio(_ bio: String) {
        defaults.set(bio, forKey: Keys.defaultBio)
    }
    
    func getDefaultBio() -> String {
        return defaults.string(forKey: Keys.defaultBio) ?? initialDefaultBio
    }
    
    // MARK: - 위치 관리
    func saveLocation(_ location: String) {
        defaults.set(location, forKey: Keys.location)
    }
    
    func getLocation() -> String {
        return defaults.string(forKey: Keys.location) ?? getDefaultLocation()
    }
    
    func saveDefaultLocation(_ location: String) {
        defaults.set(location, forKey: Keys.defaultLocation)
    }
    
    func getDefaultLocation() -> String {
        return defaults.string(forKey: Keys.defaultLocation) ?? initialDefaultLocation
    }
    
    // MARK: - 나이 관리
    func saveAge(_ age: String) {
        defaults.set(age, forKey: Keys.age)
    }
    
    func getAge() -> String {
        return defaults.string(forKey: Keys.age) ?? getDefaultAge()
    }
    
    func saveDefaultAge(_ age: String) {
        defaults.set(age, forKey: Keys.defaultAge)
    }
    
    func getDefaultAge() -> String {
        return defaults.string(forKey: Keys.defaultAge) ?? initialDefaultAge
    }
    
    // MARK: - 장르 관리
    func saveGenres(_ genres: [String]) {
        defaults.set(genres, forKey: Keys.genres)
    }
    
    func getGenres() -> [String] {
        return defaults.stringArray(forKey: Keys.genres) ?? getDefaultGenres()
    }
    
    func saveDefaultGenres(_ genres: [String]) {
        defaults.set(genres, forKey: Keys.defaultGenres)
    }
    
    func getDefaultGenres() -> [String] {
        return defaults.stringArray(forKey: Keys.defaultGenres) ?? initialDefaultGenres
    }
    
    // MARK: - 전체 프로필 관리
    func saveProfile(name: String, username: String? = nil, bio: String? = nil, location: String? = nil, age: String? = nil, genres: [String], image: UIImage? = nil) {
        saveName(name)
        if let username = username { saveUsername(username) }
        if let bio = bio { saveBio(bio) }
        if let location = location { saveLocation(location) }
        if let age = age { saveAge(age) }
        saveGenres(genres)
        if let image = image { saveProfileImage(image) }
    }
    
    // 프로필 초기화 (기본값으로 복원)
    func resetProfileToDefaults() {
        // 기존 데이터 삭제
        defaults.removeObject(forKey: Keys.name)
        defaults.removeObject(forKey: Keys.username)
        defaults.removeObject(forKey: Keys.bio)
        defaults.removeObject(forKey: Keys.location)
        defaults.removeObject(forKey: Keys.genres)
        defaults.removeObject(forKey: Keys.age)
        defaults.removeObject(forKey: Keys.profileImage)
        
        // 기본적으로 이제 get 메서드를 호출하면 기본값이 반환됨
    }
    
    // 모든 저장된 데이터 삭제 (리셋)
    func resetAllProfileData() {
        defaults.removeObject(forKey: Keys.name)
        defaults.removeObject(forKey: Keys.username)
        defaults.removeObject(forKey: Keys.bio)
        defaults.removeObject(forKey: Keys.location)
        defaults.removeObject(forKey: Keys.genres)
        defaults.removeObject(forKey: Keys.age)
        defaults.removeObject(forKey: Keys.profileImage)
        
        // 새로 추가된 데이터 삭제
        defaults.removeObject(forKey: Keys.emotionStats)
        defaults.removeObject(forKey: Keys.activityItems)
        defaults.removeObject(forKey: Keys.songs)
    }
    
    // MARK: - 새로 추가된 메서드
    
    // 감정 통계 JSON 저장 및 가져오기
    func saveEmotionStats(_ jsonString: String) {
        defaults.set(jsonString, forKey: Keys.emotionStats)
    }
    
    func getEmotionStatsJson() -> String {
        if let savedJson = defaults.string(forKey: Keys.emotionStats) {
            return savedJson
        }
        return DataManager.shared.getSampleEmotionStatsJson()
    }
    
    // 활동 아이템 JSON 저장 및 가져오기
    func saveActivityItems(_ jsonString: String) {
        defaults.set(jsonString, forKey: Keys.activityItems)
    }
    
    func getActivityItemsJson() -> String {
        if let savedJson = defaults.string(forKey: Keys.activityItems) {
            return savedJson
        }
        return DataManager.shared.getSampleActivityItemsJson()
    }
    
    // 노래 JSON 저장 및 가져오기
    func saveSongs(_ jsonString: String) {
        defaults.set(jsonString, forKey: Keys.songs)
    }
    
    func getSongsJson() -> String {
        if let savedJson = defaults.string(forKey: Keys.songs) {
            return savedJson
        }
        return DataManager.shared.getSampleSongsJson()
    }
    
    // 객체를 통한 데이터 접근
    func getEmotionStats() -> [EmotionStat]? {
        let jsonString = getEmotionStatsJson()
        return DataManager.shared.parseEmotionStats(from: jsonString)
    }
    
    func getActivityItems() -> [ActivityItem]? {
        let jsonString = getActivityItemsJson()
        return DataManager.shared.parseActivityItems(from: jsonString)
    }
    
    func getSongs() -> [Song]? {
        let jsonString = getSongsJson()
        return DataManager.shared.parseSongs(from: jsonString)
    }
}
