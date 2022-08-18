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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        return scrollView
    } ()
    
     let control: UISegmentedControl = {
        let titles = ["Following", "For you"]
        let control = UISegmentedControl(items:  titles)
        control.selectedSegmentIndex = 1
         control.backgroundColor = nil
         control.selectedSegmentTintColor = .white
        return control
    }()
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
        horizontalScrollView.delegate = self
        horizontalScrollView.contentOffset = CGPoint(x: view.width, y: 0)
        setUpHeaderButtons()
    }
    
    override func viewDidLayoutSubviews() {
        horizontalScrollView.frame = view.bounds
    }
    
    func setUpHeaderButtons() { // настройка кнопок переключения между лентой и предложкой
        
        control.addTarget(self, action: #selector(didChangeSegmentControl), for: .valueChanged)
        navigationItem.titleView = control
    }

    @objc private func didChangeSegmentControl(sender: UISegmentedControl){
        horizontalScrollView.setContentOffset(CGPoint(x: view.width *
                                                      CGFloat(sender.selectedSegmentIndex),
                                                      y: 0), animated: true)
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
        let vc = PostViewController(model: model)
        vc.delegate = self
        followingPageViewController.setViewControllers([vc],
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
        let vc = PostViewController(model: model)
        vc.delegate = self
        forYouPageViewController.setViewControllers([vc],
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
        vc.delegate = self
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
        vc.delegate = self
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

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // проверка был ли свайп влево/вправо
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x < (view.width / 2){
            control.selectedSegmentIndex =  0
        }
        else if scrollView.contentOffset.x > (view.width / 2){
            control.selectedSegmentIndex = 1
        }
    }
}

extension HomeViewController: PostViewControllerDelegate{
    func postViewController(vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        horizontalScrollView.isScrollEnabled = false
        if horizontalScrollView.contentOffset.x == 0 {
            followingPageViewController.dataSource = nil
        }
        else {
            forYouPageViewController.dataSource = nil
        }
        let vc = CommentsViewController(post: post)
        vc.delegate = self
        addChild(vc)
        vc.didMove(toParent: self)
        view.addSubview(vc.view)
        let frame: CGRect = CGRect(x: 0, y: view.height, width: view.width, height: view.height * 0.75)
        vc.view.frame = frame
        UIView.animate(withDuration: 0.2) {
            vc.view.frame = CGRect(x: 0, y: self.view.height - frame.height, width: frame.width, height: frame.height)
    }
}
    func postViewController(vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        let user = post.user
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: CommentsViewControllerDelegate {
    func didTapCloseForComments(with viewController: CommentsViewController) {
        // close comments with animation
        let frame = viewController.view.frame
        UIView.animate(withDuration: 0.2) {
            viewController.view.frame = CGRect(x: 0, y: self.view.height, width: frame.width, height: frame.height)
        }completion: { [weak self]  done in
            if done {
                DispatchQueue.main.async {
                    // remove vc as child
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                    // allow horizontal and vertical scroll
                    self?.horizontalScrollView.isScrollEnabled = true
                    self?.forYouPageViewController.dataSource = self
                    self?.followingPageViewController.dataSource = self
                }
 
            }
        }
        
        
    }
}
