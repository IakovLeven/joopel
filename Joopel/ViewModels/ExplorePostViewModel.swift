//
//  ExplorePostViewModel.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation
import UIKit

struct ExplorePostViewModel {
    let thumbNailImage: UIImage?
    let caption: String
    let handler: (() -> Void)
}
