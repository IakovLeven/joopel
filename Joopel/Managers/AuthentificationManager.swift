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
    
    enum AuthError: Error {
        case signInFailed
    }

    // MARK: -Public
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public func signIn(with email: String, password: String, completion: @escaping (Result<String, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password, completion: {result, error in
            guard  result != nil, error == nil else{
                if let error = error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(AuthError.signInFailed))
                }
                return
            }
            
            DatabaseManager.shared.getUsername(for: email) {username in
                if let username = username {
                    UserDefaults.standard.setValue(username, forKey: "username")
                }
            }
            
            // Succesful sign in
            completion(.success(email))
        })
    }
    
    public func signUp(with username: String,
                       email: String,
                       password: String,
                       completion: @escaping (Bool) -> Void
    ){
        // Make sure enterned username is available
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {result, error in
            guard result != nil, error == nil else{
                completion(false)
                return
            }
            UserDefaults.standard.setValue(username, forKey: "username")

            
            DatabaseManager.shared.insertUser(with: email, username: username, completion: completion)
            
        })
    }
    
    public func signOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
 
}

