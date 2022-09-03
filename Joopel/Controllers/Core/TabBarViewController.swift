//
//  TabBarViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    private var signInPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.barTintColor = UIColor(white: 0.5, alpha: 0.5)
        setUpControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !signInPresented {
            presentSignInIfNeeded()
        }
    }
    
    private func presentSignInIfNeeded() {
        if !AuthManager.shared.isSignedIn {
            let vc = SignInViewController()
            vc.completion = { [weak self] in
                self?.signInPresented = false
            }
            let navVc = UINavigationController(rootViewController: vc)
            navVc.modalPresentationStyle = .fullScreen
            present(navVc, animated: false, completion: nil)
        }
    }
    
    private func setUpControllers() {
        
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let notifications = NotificationsViewController()
        let profile = ProfileViewController(
            user: User(
                username: UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me",
                profilePictureURL: nil,
                identifier: UserDefaults.standard.string(forKey: "username")?.lowercased () ?? ""
            )
        )
        

        notifications.title = "Notifications"
        profile.title = "Profile"

        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: notifications)
        let nav4 = UINavigationController(rootViewController: profile)
        let cameraNav = UINavigationController(rootViewController: camera)

        nav1.navigationBar.backgroundColor = .clear
        nav1.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav1.navigationBar.shadowImage = UIImage()
        
        
        cameraNav.navigationBar.backgroundColor = .clear
        cameraNav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        cameraNav.navigationBar.shadowImage = UIImage()
        cameraNav.navigationBar.tintColor = .white
        
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag : 1)
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "raiting")?.withRenderingMode(.alwaysOriginal), tag : 1)
        camera.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal), tag : 1)
        nav3.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "message")?.withRenderingMode(.alwaysOriginal), tag : 1)
        nav4.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal), tag : 1)

        setViewControllers([nav1, nav2, cameraNav, nav3, nav4], animated: false)

    }
    

}
