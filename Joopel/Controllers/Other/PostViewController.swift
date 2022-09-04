//
//  PostViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//

import AVFoundation
import UIKit

protocol PostViewControllerDelegate: AnyObject {
    func postViewController(vc: PostViewController, didTapCommentButtonFor post: PostModel)
    func postViewController(vc: PostViewController, didTapProfileButtonFor post: PostModel)

}

class PostViewController: UIViewController {
    weak var delegate: PostViewControllerDelegate?
    var model: PostModel
    
    private let slider: UISlider = {
        let slider = UISlider()
        let sliderImage = UIImage(named: "slider_image_2")
        let topFirstImage = UIImage(named: "Slider_Top _First")
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.tintColor = .systemPink
        slider.maximumValueImage = topFirstImage
        slider.setThumbImage(sliderImage, for: .normal)
        
        return slider
    }()
    
    private let likeButton: UIButton = {// кнопка лайка
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    } ()
    
    private let commentButton: UIButton = { // кнопка коммента
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "bubble.left"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    } ()
    
    private let profileButton: UIButton = { // кнопка профиля
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "test"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        button.layer.masksToBounds = true // кружочек из кнопки
        button.imageView?.contentMode = .scaleAspectFit
        return button
    } ()
    
    private let shareButton: UIButton = { // кнопка поделиться
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "share"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    } ()
    
    private let captionLabel: UILabel = { // описание видео
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Best asses only in j00pel"
        label.textColor = .white
        label.font = .systemFont(ofSize : 26)
        return label
        
    }()
    var player: AVPlayer?
    
    private var playerDidFinishObservever: NSObjectProtocol?
    
    private let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        spinner.startAnimating()

        return spinner
    }()
    
    // MARK: -Init
    
    init (model: PostModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(videoView)
        videoView.addSubview(spinner)
        configureVideo()
        view.backgroundColor = .black

        /*let storage = Storage.storage()
         let gsReference = storage.reference(forURL: "gs://joopel-b6c66.appspot.com/photos/ylevenn/photo")
         gsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
           if let error = error {
             // Uh-oh, an error occurred!
           } else {
             // Data for "images/island.jpg" is returned
               let image = UIImage(data: data!)
               let vc = UIImageView(image: image)
               vc.frame = self.view.bounds
               self.view.addSubview(vc)
               self.setUpButtons()
               self.setUpDoubleTapToLike()
               self.view.addSubview(self.captionLabel)
               self.view.addSubview(self.profileButton)
               self.profileButton.addTarget(self, action: #selector(self.didTapProfileButton), for: .touchUpInside)
           }
         }*/
        
        setUpButtons()
        setUpDoubleTapToLike()
        view.addSubview(captionLabel)
        view.addSubview(profileButton)
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoView.frame = view.bounds
        
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = videoView.center
        
        let size: CGFloat = 40
        let yStart: CGFloat = view.height - (size * 4) - view.safeAreaInsets.bottom
        for (index, button) in [likeButton, commentButton, shareButton].enumerated(){
            button.frame = CGRect(x: view.width - size - 10,
                                  y: yStart + (CGFloat(index) * size) + (CGFloat(index) * 10),
                                  width: size,
                                  height: size)
        }
        captionLabel.sizeToFit()
        let labelSize = captionLabel.sizeThatFits(CGSize(width: view.height - size - 12,
                                                         height: view.height))
        
        slider.frame = CGRect(x: -185, y: view.height / 2 - 225, width: 450, height: 450)
        let trans: CGAffineTransform  = CGAffineTransform(rotationAngle: Double.pi * 1.5)
        slider.transform = trans
        
        captionLabel.frame = CGRect(x: 5, // настройка окна для текста
                                    y: view.height - 10 - view.safeAreaInsets.bottom - labelSize.height,
                                    width: view.width - size - 12, height: labelSize.height
        )
        
        profileButton.frame = CGRect(x: likeButton.left,
                                     y: likeButton.top - 10 - size,
                                     width: size,
                                     height: size
        )
        profileButton.layer.cornerRadius = size / 2
    }
    func setUpButtons() { // настройка кнопок
        view.addSubview(likeButton)
        view.addSubview(commentButton)
        view.addSubview(shareButton)
        view.addSubview(slider)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        
    }
    
    private func configureVideo() {
//        guard let path = Bundle.main.path(forResource: "video2", ofType: "mp4") else {
//            return
//        }
//        let url = URL(fileURLWithPath: path)
        
        StorageManager.shared.getDownloadURL(for: model) {[weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                strongSelf.spinner.stopAnimating()
                strongSelf.spinner.removeFromSuperview()
                switch result {
                    
                case .success(let url):
                    strongSelf.player = AVPlayer(url: url)
                    
                    let playerLayer = AVPlayerLayer(player: strongSelf.player)
                    playerLayer.frame = strongSelf.view.bounds
                    playerLayer.videoGravity = .resizeAspectFill
                    strongSelf.videoView.layer.addSublayer(playerLayer)
                    strongSelf.player?.volume = 0
                    strongSelf.player?.play()
                case .failure:
                    guard let path = Bundle.main.path(forResource: "video2", ofType: "mp4") else {
                        return
                    }
                    let url = URL(fileURLWithPath: path)
                    strongSelf.player = AVPlayer(url: url)
                    
                    let playerLayer = AVPlayerLayer(player: strongSelf.player)
                    playerLayer.frame = strongSelf.view.bounds
                    playerLayer.videoGravity = .resizeAspectFill
                    strongSelf.videoView.layer.addSublayer(playerLayer)
                    strongSelf.player?.volume = 0
                    strongSelf.player?.play()
                }
            }
        }
        
        
        
        guard let player = player else {
            return
        }

        playerDidFinishObservever = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) {_ in
            player.seek(to: .zero)
            player.play()
        }
        
        
    }
    
    @objc private func didTapProfileButton() {
        delegate?.postViewController(vc: self, didTapProfileButtonFor: model )
    }
    @objc private func didTapLike() {
        model.isLikedByCurrentUser = !model.isLikedByCurrentUser
        
        likeButton.tintColor = model.isLikedByCurrentUser ? .red : .white
    }
    @objc private func didTapComment() {
        delegate?.postViewController(vc: self, didTapCommentButtonFor: model)
    }
    @objc private func didTapShare () {
        guard let url = URL(string: "https://www.tiktok.com") else {
            return
        }
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: [])
        present(vc, animated: true)
    }
    
    func setUpDoubleTapToLike() { // лайк двойным тапом
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(gesture:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func sliderDidChangeValue() {
        print(slider.value)
        if 0.0 <= slider.value, slider.value < 25.0 {
            slider.maximumValueImage = UIImage(named: "Slider_Top _First")
        }
        else if 25.0 <= slider.value, slider.value < 50.0 {
            slider.maximumValueImage = UIImage(named: "Slider_Top _Second")
        }
        else if 50.0 <= slider.value, slider.value < 75.0 {
            slider.maximumValueImage = UIImage(named: "Slider_Top_Third")
        }
        else if 75.0 <= slider.value, slider.value <= 100.0 {
            slider.maximumValueImage = UIImage(named: "Slider_Top")
        }
        
    }
    
    @objc private func didDoubleTap(gesture: UITapGestureRecognizer){
        if !model.isLikedByCurrentUser {
            model.isLikedByCurrentUser = true
        }
        let touchPoint = gesture.location(in: view)
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        
        imageView.tintColor = .systemRed
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.center = touchPoint
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 1
        } completion: { done in
            if done { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.3) {
                    imageView.alpha = 0
                } completion: { done in
                    if done {
                        imageView.removeFromSuperview()
                    }
                }
            }}
        }
        
    }
}
