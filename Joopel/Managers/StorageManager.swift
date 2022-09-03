//
//  StorageManager.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    public static let shared = StorageManager()
    
    private let storageBucket = Storage.storage().reference()
    
    private init() {}
    
    // Public
    
    public func getVideoURL(with identifier : String, completion :(URL) -> Void) {
        
    }
    
    public func uploadVideo(from url: URL, filename: String, completion: @escaping  (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        storageBucket.child("videos/\(username)/\(filename)").putFile(from: url, metadata: nil) {
            _, error in
            completion(error == nil)
        }
    }
    
    public func uploadPhoto(from data: Data?, filename: String) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }

        storageBucket.child("photos/\(username)/\(filename)").putData(data ?? Data(), metadata: nil) {
            _, error in
            return
        }
        
    }
    
    public func generateVideoName() -> String {
        let uuidString = UUID().uuidString
        let number = Int.random(in: 0...1000)
        let unixTimestamp = Date().timeIntervalSince1970
        
        return uuidString + "_" + "\(number)" + "_" + "\(unixTimestamp)" + ".mov"
    }
}
