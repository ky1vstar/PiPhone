//
//  CustomPlayerViewController.swift
//  Example Swift
//
//  Created by KY1VSTAR on 11.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

import UIKit
import AVKit

protocol CustomPlayerViewControllerDelegate: class {
    
    func customPlayerViewController(_ customPlayerViewController: CustomPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void)
    
}

class CustomPlayerViewController: UIViewController {
    
    @IBOutlet var playerView: PlayerView!
    @IBOutlet var pipToggleButton: UIButton!
    
    weak var delegate: CustomPlayerViewControllerDelegate?
    var player: AVPlayer?
    private var pictureInPictureController: AVPictureInPictureController!
    private var pictureInPictureObservations = [NSKeyValueObservation]()
    private var strongSelf: Any?
    
    deinit {
        // without this line vanilla AVPictureInPictureController will crash due to KVO issue
        pictureInPictureObservations = []
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.playerLayer.player = player
        
        setupPictureInPicture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player?.play()
    }
    
    // https://developer.apple.com/documentation/avkit/adopting_picture_in_picture_in_a_custom_player
    func setupPictureInPicture() {
        pipToggleButton.setImage(AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil), for: .normal)
        pipToggleButton.setImage(AVPictureInPictureController.pictureInPictureButtonStopImage(compatibleWith: nil), for: .selected)
        pipToggleButton.setImage(AVPictureInPictureController.pictureInPictureButtonStopImage(compatibleWith: nil), for: [.selected, .highlighted])
        
        guard AVPictureInPictureController.isPictureInPictureSupported(),
            let pictureInPictureController = AVPictureInPictureController(playerLayer: playerView.playerLayer) else {
                
                pipToggleButton.isEnabled = false
                return
        }
        
        self.pictureInPictureController = pictureInPictureController
        pictureInPictureController.delegate = self
        pipToggleButton.isEnabled = pictureInPictureController.isPictureInPicturePossible
        
        pictureInPictureObservations.append(pictureInPictureController.observe(\.isPictureInPictureActive) { [weak self] pictureInPictureController, change in
            guard let `self` = self else { return }
            
            self.pipToggleButton.isSelected = pictureInPictureController.isPictureInPictureActive
        })
        
        pictureInPictureObservations.append(pictureInPictureController.observe(\.isPictureInPicturePossible) { [weak self] pictureInPictureController, change in
            guard let `self` = self else { return }
            
            self.pipToggleButton.isEnabled = pictureInPictureController.isPictureInPicturePossible
        })
    }
    
    // MARK: - Actions
    @IBAction func pipToggleButtonTapped() {
        if pipToggleButton.isSelected {
            pictureInPictureController.stopPictureInPicture()
        } else {
            pictureInPictureController.startPictureInPicture()
        }
    }

}

// MARK: - AVPictureInPictureControllerDelegate
extension CustomPlayerViewController: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        strongSelf = self
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        strongSelf = nil
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if let delegate = delegate {
            delegate.customPlayerViewController(self, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
        } else {
            completionHandler(true)
        }
    }
    
}
