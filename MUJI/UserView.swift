//
//  UserView.swift
//  MUJI
//
//  Created by 조수원 on 3/19/25.
//

import UIKit
import SwiftUI
import Combine

class UserViewController: UIViewController {
    
    // 뷰모델 인스턴스
    let userViewModel = UserViewModel()
    
    // UI 요소들
    var nameTextField: UITextField!
    var ageTextField: UITextField!
    var musicGenreTextField: UITextField!
    var profileImageView: UIImageView!
    var saveButton: UIButton!
    var deleteButton: UIButton!
    var userListTableView: UITableView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI 설정
        setupUI()
        
        // 사용자 데이터 갱신 시 UI 업데이트
        userViewModel.$users
            .sink { [weak self] _ in
                self?.updateUserListUI()
            }
            .store(in: &cancellables)
        
        // 사용자 정보 불러오기
        userViewModel.fetchUsers()
    }
    
    // UI 구성
    private func setupUI() {
        // Name TextField
        nameTextField = UITextField()
        nameTextField.placeholder = "Enter Name"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        // Age TextField
        ageTextField = UITextField()
        ageTextField.placeholder = "Enter Age"
        ageTextField.keyboardType = .numberPad
        ageTextField.borderStyle = .roundedRect
        view.addSubview(ageTextField)
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20).isActive = true
        ageTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        // Music Genre TextField
        musicGenreTextField = UITextField()
        musicGenreTextField.placeholder = "Enter Music Genre"
        musicGenreTextField.borderStyle = .roundedRect
        view.addSubview(musicGenreTextField)
        musicGenreTextField.translatesAutoresizingMaskIntoConstraints = false
        musicGenreTextField.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20).isActive = true
        musicGenreTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        musicGenreTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        // Profile ImageView
        profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.contentMode = .scaleAspectFit
        view.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.topAnchor.constraint(equalTo: musicGenreTextField.bottomAnchor, constant: 20).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Save Button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save User", for: .normal)
        saveButton.addTarget(self, action: #selector(saveUser), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Delete Button
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete First User", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // User List Table View
        userListTableView = UITableView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        view.addSubview(userListTableView)
        userListTableView.translatesAutoresizingMaskIntoConstraints = false
        userListTableView.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 20).isActive = true
        userListTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        userListTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        userListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // UI 업데이트
    private func updateUserListUI() {
        userListTableView.reloadData()
    }
    
    // 사용자 저장
    @objc private func saveUser() {
        guard let name = nameTextField.text,
              let age = Int(ageTextField.text ?? ""),
              let musicGenre = musicGenreTextField.text else { return }
        
        let profileImage = profileImageView.image ?? UIImage() // 기본 이미지
        userViewModel.addUser(name: name, age: age, profileImage: profileImage, musicGenre: musicGenre)
    }
    
    // 첫 번째 사용자 삭제
    @objc private func deleteUser() {
        userViewModel.deleteUser(at: 0) // 첫 번째 사용자 삭제
    }
}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
        let user = userViewModel.users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "\(user.age) - \(user.musicGenre)"
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    
}

#Preview {
    UserViewController()
}
