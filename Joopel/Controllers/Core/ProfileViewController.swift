//
//  ProfileViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import ProgressHUD
import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    var user: User
    
    var isCurrentUserProfile: Bool {
        if let username = UserDefaults.standard.string(forKey: "username") {
            return user.username.lowercased() == username
        }
        return false
    }
    
    enum PickturePickerType {
        case camera
        case photoLibrary
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.showsVerticalScrollIndicator = false
        collection.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
        )
        collection.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        return collection
        
    }()
    
    private var posts = [PostModel]()
    
    
    // MARK: -Init
    
    init(user: User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let username = UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me"
        if title == username {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }
        fetchPosts()
    }
    
    func fetchPosts() {
        DatabaseManager.shared.getPosts(for: user) {[weak self ] postModels in
            DispatchQueue.main.async {
                self?.posts = postModels
                self?.collectionView.reloadData()
            }
            
        }
    }
    
    @objc func didTapSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: -CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postModel = posts[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostCollectionViewCell.identifier,
            for: indexPath
        ) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: postModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(model: post)
        vc.delegate = self
        vc.title = "Video"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.width - 12) / 3
        return CGSize(width: width, height: width * 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.delegate = self
        let viewModel = ProfileHeaderViewModel(
            avatatImageURL: user.profilePictureURL,
            followersCount: 120,
            followingCount: 200,
            isFollowing: isCurrentUserProfile ? nil : false
        )
            header.configure(with: viewModel)

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }

}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDelegate(_ header: ProfileHeaderCollectionReusableView,
                                                     didTapPrimaryButtonWith viewModel: ProfileHeaderViewModel) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        if self.user.username == currentUsername {
            // Edit profile
        }
        else {
            // Follow or unfollow users profile
        }
    }
    
    func profileHeaderCollectionReusableViewDelegate(_ header: ProfileHeaderCollectionReusableView,
                                                     didTapFollowingButtonWith viewModel: ProfileHeaderViewModel) {
        let vc = UserListViewController(type: .following, user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCollectionReusableViewDelegate(_ header: ProfileHeaderCollectionReusableView,
                                                     didTapFollowersButtonWith viewModel: ProfileHeaderViewModel) {
        let vc = UserListViewController(type: .followers, user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCollectionReusableViewDelegate(_ header: ProfileHeaderCollectionReusableView, didTapAvatarFor viewModel: ProfileHeaderViewModel) {
        guard isCurrentUserProfile else {
            return
        }
        let actionSheet = UIAlertController(title: "Profile Picture", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .camera)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.presentProfilePicturePicker(type: .photoLibrary)
            }
        }))

        present(actionSheet, animated: true)
    }
    
    func presentProfilePicturePicker(type: PickturePickerType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type == .camera ? .camera : .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        ProgressHUD.show("Uploading")
        StorageManager.shared.uploadProfilePicture(with: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let downloadURL):
                    UserDefaults.standard.setValue(downloadURL.absoluteString, forKey: "profile_picture_url")
                    strongSelf.user = User(
                        username: strongSelf.user.username,
                        profilePictureURL: downloadURL,
                        identifier: strongSelf.user.username
                    )
                    ProgressHUD.showSucceed("Updated!")
                    strongSelf.collectionView.reloadData()
                case .failure:
                    ProgressHUD.showError("Failed to upload profile picture")
                }
            }
        }
     }
}

extension ProfileViewController: PostViewControllerDelegate {
    
    func postViewController(vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        
    }

    func postViewController(vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        
    }
}

