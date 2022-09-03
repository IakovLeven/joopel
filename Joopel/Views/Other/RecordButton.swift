//
//  RecordButton.swift
//  Joopel
//
//  Created by Яков Левен on 23.08.2022.
//

import UIKit

class RecordButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = nil
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.5
    }

    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = height / 2
    }
    enum State {
        case recording
        case notRecording
    }
    public func toggle(for state: State){
        switch state {
        case .recording:
            backgroundColor = .systemPink
        case .notRecording:
            backgroundColor = nil
        }
    }
}
