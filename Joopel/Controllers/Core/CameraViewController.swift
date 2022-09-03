//
//  CameraViewController.swift
//  Joopel
//
//  Created by Яков Левен on 08.08.2022.
//
/*
import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    
    // Capture Session
    
    var captureSession = AVCaptureSession()
    
    // Capture Device
    
    var captureDevice:  AVCaptureDevice?
    
    // Capture Output
    
    var capatureOutput = AVCaptureMovieFileOutput()
    
    // Capture Preview
    
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let cameraView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .black
        return view
    }()
    
    private let recordButton = RecordButton()
    
    private var previewLayer: AVPlayerLayer?
    
    private var recordedVideoURL: URL?
    
    //MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cameraView)
        view.backgroundColor = .systemBackground
        setUpCamera()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        view.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.frame = view.bounds
        let size: CGFloat = 70
        recordButton.frame = CGRect(x: (view.width - size) / 2, y: view.height - view.safeAreaInsets.bottom - size - 5, width: size, height: size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func didTapClose() {
        navigationItem.rightBarButtonItem = nil
        recordButton.isHidden = false
        if previewLayer != nil {
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
        }
        else {
            captureSession.stopRunning()
            tabBarController?.tabBar.isHidden = false
            tabBarController?.selectedIndex = 0
        }
    }
    
    @objc private func didTapNext() {
        guard let url = recordedVideoURL else {
            return
        }
        // Push caption controller
        let vc = CaptionViewController(videoURL: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRecord() {
        if capatureOutput.isRecording {
            // stop recording
            recordButton.toggle(for: .notRecording)
            capatureOutput.stopRecording()
        }
        else {
            //start recording
            guard var url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else {
                return
            }
            
            url.appendPathComponent("video.mov")
            
            recordButton.toggle(for: .recording)
            
            try? FileManager.default.removeItem(at: url)
            
            capatureOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    func setUpCamera() {
        // Add Devices
        
        if let audioDevice = AVCaptureDevice.default(for: .audio){
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice)
            if let audioInput = audioInput {
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            }
        }
        
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            if let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
                if captureSession.canAddInput(videoInput){
                    captureSession.addInput(videoInput)
                }
            }
        }
        // Update Session
        
        captureSession.sessionPreset = .hd1280x720
        if captureSession.canAddOutput(capatureOutput) {
            captureSession.addOutput(capatureOutput)
        }
        
        // Configure Preview
        
        capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer?.videoGravity = .resizeAspectFill
        capturePreviewLayer?.frame = view.bounds
        if let layer = capturePreviewLayer {
            cameraView.layer.addSublayer(layer)
        }
        
        
        // Enable Camera Start
        captureSession.startRunning()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        guard error == nil else {
            let alert = UIAlertController(title: "Wooops", message: "Something went wrong when recording your video", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        recordedVideoURL = outputFileURL
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
        
        let player = AVPlayer(url: outputFileURL)
        let previewLayer = AVPlayerLayer(player: player)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        recordButton.isHidden = true
        cameraView.layer.addSublayer(previewLayer)
        
        previewLayer.player?.play()
    }
}
 */






import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    var session: AVCaptureSession?
    
    let output = AVCapturePhotoOutput()
    
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    private var photoOutputURL: URL?
    
    private var outputImage: UIImage?
    
    private let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        button.layer.cornerRadius = 100
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(button)
        checkCameraPermissions()
        
        button.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside )
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame =  view.bounds
        
        button.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 200)
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for:  .video) {[weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
                
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
    
                self.session = session
            }
            
            catch {
                print(error)
            }
        }
    }
    
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
    @objc private func didTapNext(with image: UIImage?) {
        let imageData = outputImage?.jpegData(compressionQuality: 0.8)
        guard imageData != nil else {
            return
        }
        StorageManager.shared.uploadPhoto(from: imageData, filename: "\(Date().timeIntervalSince1970)_photo")
        navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        outputImage = image
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
    
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
        
}

