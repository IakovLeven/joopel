//
//  AuthField.swift
//  Joopel
//
//  Created by Яков Левен on 18.08.2022.
//

import UIKit

class AuthField: UITextField {

    enum FieldType {
        case email
        case password
        case username
        
        var title: String {
            switch self{
                
            case .email:
                return "Email adress"
            case .password:
                return "Password"
            case .username:
                return "Username"
            }
        }
    }
    
    private let type: FieldType
    
    init(type: FieldType) {
        self.type = type
        super.init(frame: .zero)
        configureUI()
    }
     
    required init?(coder: NSCoder){
        fatalError()
    }
    
    private func configureUI() {
        autocapitalizationType = .none
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true
        placeholder = type.title
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: height))
        leftViewMode = .always
        returnKeyType = .done
        autocorrectionType = .no
        
        if type == .password {
            textContentType = .oneTimeCode
            isSecureTextEntry = true
        }
        else  if type == .email {
            keyboardType = .emailAddress
            textContentType = .emailAddress
        }
    }
    
}
