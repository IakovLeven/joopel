//
//  ExploreBannerViewModel.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation
import UIKit

struct ExploreBannerViewModel {
    let image: UIImage?
    let title: String
    let handler: (() -> Void)
}
