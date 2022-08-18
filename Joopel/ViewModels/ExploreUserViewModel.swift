//
//  ExploreUserViewModel.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation
import UIKit

struct ExploreUserViewModel {
    let profilePicture: UIImage?
    let username: String
    let followerCount: Int
    let handler: (() -> Void)
}
 
