//
//  Notifications.swift
//  Joopel
//
//  Created by Яков Левен on 30.08.2022.
//

import Foundation

enum NotificationType {
    case postLike(postName: String)
    case userFollow(username: String)
    case postComment(postName: String)
    
    var id: String {
        switch self {
            case .postLike: return "postLike"
            case .userFollow: return "userFollow"
            case .postComment: return "postComment"
            
        }
    }
}

class Notification {
    var identifier = UUID().uuidString
    var isHidden = false
    let text: String
    let type: NotificationType
    let date: Date
    
    init(text: String, type: NotificationType, date: Date) {
        self.text = text
        self.type = type
        self.date = date
    }
    
    static func mockData() -> [Notification]{
        let first = Array(0...5).compactMap({
            Notification(text: "Something happend \($0)",
                         type: .postComment(postName: "GayFish"),
                         date: Date()
            )
            
        })
        let second = Array(0...5).compactMap({
            Notification(text: "Something happend \($0)",
                         type: .userFollow(username: "GayFish"),
                         date: Date()
            )
            
        })
        let third = Array(0...5).compactMap({
            Notification(text: "Something happend \($0)",
                         type: .postLike(postName: "GayFish"),
                         date: Date()
            )
            
        })
        return first + second + third
    }
}
