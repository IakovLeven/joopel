//
//  DatabaseManager.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

final class DatabaseManager {
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    
    private init() {}
    
    // Public
    

    
    public func insertUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
    
        database.child("users").observeSingleEvent(of: .value, with: {[weak self] snapshot in
            guard var usersDictionary = snapshot.value as? [String: Any] else {
                // create user root node
                self?.database.child("users").setValue(
                    [
                        username: [
                            "email": email
                            
                        ]
                    ],
                    withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    }
                )
                return
            }
            
            usersDictionary[username] = ["email": email]
            // save new user object
            self?.database.child("users").setValue(usersDictionary, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })

    }
    
    public func getAllUsers(completion : ([String]) -> Void) {
        
    }
    
    public func markNotificationsAsHidden(notificationID: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    public func follow(username: String, completion: @escaping (Bool) -> Void){
        completion(true)
    }
    
    
    public func getNotifications(completion: @escaping ([Notification]) -> Void) {
        completion(Notification.mockData())
    }
    
    public func getUsername(for email: String, completion: @escaping (String?) -> Void){
        database.child("users").observeSingleEvent(of: .value)  {snapshot in
            guard let users = snapshot.value as? [String: [String: Any]] else {
                completion(nil)
                return
            }
            
            for (username, value) in users {
                if value["email"] as? String == email {
                    completion(username)
                    break
                }
            }
        }
    }
    
    public func insertPost(caption: String, filename: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        database.child("users").child(username).observeSingleEvent(of: .value) {[weak self] snapshot in
            guard var value = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            let newEntry = [
                "name": filename,
                "caption": caption
            ]
            
            if var posts = value["posts"] as? [[String: Any]] {
                posts.append(newEntry)
                value["posts"] = posts
                self?.database.child("users").child(username).setValue(value) {
                    error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
            else {
                value["posts"] = [newEntry]
                self?.database.child("users").child(username).setValue(value) {
                    error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
            
        }
    }
    
    public func getPosts(for user: User, completion: @escaping ([PostModel]) -> Void) {
        
        let path = "users/\(user.username.lowercased())/posts"
        database.child(path).observeSingleEvent(of: .value) {snapshot in
            guard let posts = snapshot.value as? [[String : String]] else {
                completion([])
                return
            }
            
            let models: [PostModel] = posts.compactMap({
                var model = PostModel(identifier: UUID().uuidString,
                          user: user)
                model.fileName = $0["name"] ?? ""
                model.caption = $0["caption"] ?? ""
                return model
            })
            
            completion(models)
        }
    }
    
}
