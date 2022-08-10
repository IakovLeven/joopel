//
//  PostViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import UIKit

class PostViewController: UIViewController {

    let model: PostModel
    
    init (model: PostModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let colors: [UIColor] = [
            .red, .green, .blue, .brown, .black, .white, .yellow, .orange
        ]
        view.backgroundColor = colors.randomElement()
    }
    

    
}
