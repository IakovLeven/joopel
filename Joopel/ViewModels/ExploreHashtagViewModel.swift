//
//  ExploreHashtagViewModel.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation
import UIKit

struct ExploreHashtagViewModel {
    let text: String
    let icon: UIImage?
    let count: Int // number of posts associated with tag
    let handler: (() -> Void)
}
