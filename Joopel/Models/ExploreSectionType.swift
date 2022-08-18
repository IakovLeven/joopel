//
//  ExploreSectionType.swift
//  Joopel
//
//  Created by Яков Левен on 16.08.2022.
//

import Foundation

enum ExploreSectionType: CaseIterable  {
    case banners
    case trendingPosts
    case trendingHashTags
    case recomended
    case popular
    case new
    case users

    
    var title: String {
        switch self {
        case .banners:
            return "Featured"
        case .trendingPosts:
            return "Trending videos"
        case .trendingHashTags:
            return "Hashtags"
        case .recomended:
            return "Recomended"
        case .popular:
            return "Popular"
        case .new:
            return "Recently posted"
        case .users:
            return "Popular creators"
        }
    }
}
