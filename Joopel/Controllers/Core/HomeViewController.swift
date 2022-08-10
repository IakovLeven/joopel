//
//  ViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import UIKit

class HomeViewController: UIViewController {

    let horizontalScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.backgroundColor = .red
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    } ()
    
    let forYouPageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    let followingPageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var forYouPosts = PostModel.mockModels()
    private var followingPosts = PostModel.mockModels()

    
    // Lificycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(horizontalScrollView)
        setUpFeed()
        horizontalScrollView.contentOffset = CGPoint(x: view.width, y: 0)
    }
    
    override func viewDidLayoutSubviews() {
        horizontalScrollView.frame = view.bounds
    }

    private func setUpFeed() {
        
        horizontalScrollView.contentSize = CGSize(width: view.width * 2, height: view.height)
        setUpFollowingFeed()
        setUpForYouFeed()
    }
     
    func setUpFollowingFeed() { // горизонтальные свайпы
        guard let model = followingPosts.first else {
            return
        } // берет первый пост из подписок
        
        followingPageViewController.setViewControllers([PostViewController(model: model )],
                                            direction: .forward,
                                            animated: false,
                                            completion: nil)
        followingPageViewController.dataSource = self
        
        horizontalScrollView.addSubview(followingPageViewController.view)
        followingPageViewController.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: horizontalScrollView.width,
                                             height: horizontalScrollView.height)
        addChild(followingPageViewController)
        followingPageViewController.didMove(toParent: self)
    }
    
    func setUpForYouFeed() { // вертикальные свайпы
        guard let model = forYouPosts.first else {
            return
        } // берет первый пост из предложки
        
        forYouPageViewController.setViewControllers([PostViewController(model: model )],
                                            direction: .forward,
                                            animated: false,
                                            completion: nil)
        
        forYouPageViewController.dataSource = self
        
        horizontalScrollView.addSubview(forYouPageViewController.view)
        forYouPageViewController.view.frame = CGRect(x: view.width,
                                             y: 0,
                                             width: horizontalScrollView.width,
                                             height: horizontalScrollView.height)
        addChild(forYouPageViewController)
        forYouPageViewController.didMove(toParent: self)
    }
}

extension HomeViewController : UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // движение по ленте вверх, определяет, есть ли предыдущий пост, если есть, возвращает его
        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }
        
        guard let index = currentPosts.firstIndex(where: {$0.identifier == fromPost.identifier}) else {
            return nil
            
        }
        if index == 0 {
            return nil
        }
        let priorIndex = index - 1
        let model = currentPosts[priorIndex]
        let vc = PostViewController(model: model)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? PostViewController)?.model else {
            return nil
        }
        
        guard let index = currentPosts.firstIndex(where: {$0.identifier == fromPost.identifier}) else {
            return nil
            
        }
        guard index < (currentPosts.count - 1) else { // проверка на наличие поста
            return nil
        }
        let nextIndex = index + 1
        let model = currentPosts[nextIndex]
        let vc = PostViewController(model: model)
        return vc
    }
    
    var currentPosts : [PostModel]  { // определяет какие предложить посты
        if horizontalScrollView.contentOffset.x == 0 {
            // Followig
            return followingPosts
        }
        // For you
        return forYouPosts
    }
}
