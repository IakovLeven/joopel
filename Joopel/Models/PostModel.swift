//
//  PostModel.swift
//  Joopel
//
//  Created by Яков Левен on 10.08.2022.
//

import Foundation


struct PostModel {
    let identifier: String
    var fileName: String = ""
    var caption: String = ""
    let user: User
    var isLikedByCurrentUser = false
    
    static func mockModels() -> [PostModel]{
        var posts = [PostModel]()
        for _ in 0...100{
            let post = PostModel(identifier: UUID().uuidString, user: User(
                username: "kanyewest",
                profilePictureURL: nil,
                identifier: UUID().uuidString))
            posts.append(post)
        }
        return posts
        
    }
    
    var videoChildPath: String {
        return "videos/\(user.username.lowercased())/\(fileName)"
    }
}
