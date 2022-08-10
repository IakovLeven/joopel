//
//  PostModel.swift
//  Joopel
//
//  Created by Яков Левен on 10.08.2022.
//

import Foundation


struct PostModel {
    let identifier: String
    
    static func mockModels() -> [PostModel]{
        var posts = [PostModel]()
        for _ in 0...100{
            let post = PostModel(identifier: UUID().uuidString)
            posts.append(post)
        }
        return posts
    
    }
}
