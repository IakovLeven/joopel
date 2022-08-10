//
//  AuthentificationManager.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    public static let shared = AuthManager()
    
    
    private init() {}
    
    enum SignInMethod{
        case email
        case google
        case facebook
    }
    
    public func signIn(with method: SignInMethod){
        
    }
}

public func signOut() {
    
}
