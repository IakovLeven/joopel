//
//  ExploreCell.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation
import UIKit

enum ExploreCell {
    case banner(viewModel :  ExploreBannerViewModel)
    case post(viewModel : ExplorePostViewModel)
    case hashtag(viewModel : ExploreHashtagViewModel)
    case user(viewModel : ExploreUserViewModel)

}
