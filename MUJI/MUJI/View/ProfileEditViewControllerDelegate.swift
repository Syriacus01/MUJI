
//
//  ProfileEditViewControllerDelegate.swift
//  MUJI
//
//  Created by 원대한 on 3/18/25.
//

import Foundation
import UIKit

protocol ProfileEditViewControllerDelegate: AnyObject {
    func didUpdateProfile(name: String, age: String, genres: [String], image: UIImage?)
}
