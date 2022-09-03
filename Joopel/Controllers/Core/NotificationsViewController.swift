//
//  NotificationsViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var notifications = [Notification]()
    
    private let noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "No Notifications"
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        table.register(
            NotificationsUserFollowTableViewCell.self,
            forCellReuseIdentifier: NotificationsUserFollowTableViewCell.identifier
        )
        table.register(
            NotificationsPostCommentTableViewCell.self,
            forCellReuseIdentifier: NotificationsPostCommentTableViewCell.identifier
        )
        table.register(
            NotificationsPostLikeTableViewCell.self,
            forCellReuseIdentifier: NotificationsPostLikeTableViewCell.identifier
        )
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.startAnimating()
        return spinner
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noNotificationsLabel)
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = control
        
        fetchNotifications()
    }
    
    @objc func didPullToRefresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        
        DatabaseManager.shared.getNotifications { [weak self] notifications in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self?.notifications = notifications
                self?.tableView.reloadData()
                sender.endRefreshing()
            }

        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNotificationsLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        noNotificationsLabel.center = view.center
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
    }
    
    func fetchNotifications() {
        DatabaseManager.shared.getNotifications {[weak self] notifications in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                self?.spinner.isHidden = true
                self?.notifications = notifications
                self?.updateUI()
            }
        }
    }
    
    func updateUI() {
        if notifications.isEmpty {
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noNotificationsLabel.isHidden = true
            tableView.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    
    
    //MARK: -TABLE VIEW
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = notifications[indexPath.row]
        
        switch model.type {
            
        case .postLike(let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsPostLikeTableViewCell.identifier, for: indexPath
            ) as? NotificationsPostLikeTableViewCell else {
                return tableView.dequeueReusableCell(
                    withIdentifier: "cell",
                    for: indexPath
                )
            }
            cell.delegate = self
            cell.configure(with: postName, model: model)
            return cell
        case .userFollow(let username):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsUserFollowTableViewCell.identifier, for: indexPath
            ) as? NotificationsUserFollowTableViewCell else {
                return tableView.dequeueReusableCell(
                    withIdentifier: "cell",
                    for: indexPath
                )
            }
            cell.delegate = self
            cell.configure(with: username, model: model)
            return cell
        case .postComment(let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsPostCommentTableViewCell.identifier, for: indexPath
            ) as? NotificationsPostCommentTableViewCell else {
                return tableView.dequeueReusableCell(
                    withIdentifier: "cell",
                    for: indexPath
                )
            }
            cell.delegate = self
            cell.configure(with: postName, model: model)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        var model = notifications[indexPath.row]
        model.isHidden = true
        
        DatabaseManager.shared.markNotificationsAsHidden(notificationID: model.identifier) {[weak self] succes in
            DispatchQueue.main.async {
                if succes{
                    self?.notifications = self?.notifications.filter({ $0.isHidden == false}) ?? []
                    
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .none)
                    tableView.endUpdates()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}

extension NotificationsViewController: NotificationsUserFollowTableViewCellDelegate {
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapFollowFor username: String) {
        
        DatabaseManager.shared.follow(username: username) {succes in
            if !succes {
                print("Something failed")
            }
        }
    }
    
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapAvatarFor username: String) {
        let vc = ProfileViewController(user: User(
            username: username,
            profilePictureURL: nil,
            identifier: "2123"
        ))
        vc.title = username.uppercased()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NotificationsViewController: NotificationsPostLikeTableViewCellDelegate {
    func notificationsPostLikeTableViewCell(_ cell: NotificationsPostLikeTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)

    }
    
    
}

extension NotificationsViewController: NotificationsPostCommentTableViewCellDelegate{
    
    func notificationsPostCommentTableViewCell(_ cell: NotificationsPostCommentTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)
    }
}

extension NotificationsViewController{
    func openPost(with identifier: String) {
        // resolve the post model from database\
        let vc = PostViewController(model: PostModel(identifier: identifier))
        vc.title = "Video"
        navigationController?.pushViewController(vc, animated: true)
    }
}
