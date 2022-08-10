//
//  DatabaseManager.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    public static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    private init() {}
    
    // Public
    
    public func getAllUsers(completion : ([String]) -> Void) {
        
    }
}
