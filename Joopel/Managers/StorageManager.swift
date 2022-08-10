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
    
    private let database = Storage.storage().reference()
    
    private init() {}
    
    // Public
    
    public func getVideoURL(with identifier : String, completion :(URL) -> Void) {
        
    }
    
    public func uploadVideoURL(from url: URL) {
        
    }
}
