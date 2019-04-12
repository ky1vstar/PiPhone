//
//  ViewController.swift
//  PiPhone Example
//
//  Created by KY1VSTAR on 10.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

import UIKit
import AVKit
import PiPhone

class ViewController: UIViewController {
    
    let urls = ["https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
                "https://video.twimg.com/ext_tw_video/1110679043915935745/pu/vid/720x1280/6OeRxCMr3tYaDNLB.mp4?tag=8",
                "http://www.exit109.com/~dnn/clips/RW20seconds_1.mp4"] // unsupported video
    
    let adjustmentBehaviors = [(behavior: PiPManagerContentInsetAdjustmentBehavior.navigationBar, title: "Navigation bar"),
                               (.tabBar, "Tab bar"),
                               (.navigationAndTabBars, "Navigation and Tab bars"),
                               (.safeArea, "Safe area"),
                               (.none, "None")]
    
    var topPresentedViewController: UIViewController {
        var viewController: UIViewController = self
        
        while let vc = viewController.presentedViewController {
            viewController = vc
        }
        
        return viewController
    }
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.tabBarItem.image = AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil)
        
        if !PiPManager.isSettedUp {
            containerView.isUserInteractionEnabled = false
            containerView.alpha = 0.6
            
            pickerView.isUserInteractionEnabled = false
            pickerView.alpha = 0.6
        }
    }
    
    func constructPlayer() -> AVPlayer {
        let playerItems = urls.compactMap(URL.init(string:)).map(AVPlayerItem.init)
        
        return AVQueuePlayer(items: playerItems)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? CustomPlayerViewController else {
            return
        }
        
        controller.delegate = self
        controller.player = constructPlayer()
    }
    
    // MARK: - Actions
    @IBAction func avPlayerViewControllerButtonTapped() {
        let controller = AVPlayerViewController()
        controller.delegate = self
        controller.player = constructPlayer()
        
        present(controller, animated: true, completion: nil)
    }

    @IBAction func switchValueChanged(_ switchView: UISwitch) {
        PiPManager.isPictureInPicturePossible = switchView.isOn
    }

}

// MARK: - UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return adjustmentBehaviors.count
    }
    
}

// MARK: - UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return adjustmentBehaviors[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UIView.animate(withDuration: 0.25) {
            PiPManager.contentInsetAdjustmentBehavior = self.adjustmentBehaviors[row].behavior
        }
    }
    
}

// MARK: - AVPlayerViewControllerDelegate
extension ViewController: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if playerViewController.presentingViewController != nil {
            completionHandler(true)
            return
        }
        
        topPresentedViewController.present(playerViewController, animated: true)
        completionHandler(true)
    }
    
//    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
//        return false
//    }
    
}

// MARK: - CustomPlayerViewControllerDelegate
extension ViewController: CustomPlayerViewControllerDelegate {
    
    func customPlayerViewController(_ customPlayerViewController: CustomPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        if navigationController!.viewControllers.index(of: customPlayerViewController) != nil {
            completionHandler(true)
        } else {
            navigationController!.pushViewController(customPlayerViewController, animated: true)
            completionHandler(true)
        }
    }

}
