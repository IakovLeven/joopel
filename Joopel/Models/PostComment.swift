//
//  PostComment.swift
//  Joopel
//
//  Created by Яков Левен on 14.08.2022.
//

import Foundation

struct PostComment {
    let text: String
    let user: User
    let date: Date
    
    static func mockComments() -> [PostComment] {
        let user = User(username: "kanyeWest",
                        profilePictureURL: nil,
                        identifier: UUID().uuidString)
       var comments = [PostComment]()
        
        let text = [
            "AWESOME Post man",
            "God damn its great",
            "nice ass bro",
            "so fuuuuuuuuuuuuuucking hot asdas da ad asd as das da sd asd "
        ]
        
        for comment in text {
            comments.append(PostComment(text: comment,
                                        user: user,
                                        date: Date( )
                                       )
            )
        }
       
        return comments
        
    }
    
}
