//
//  IntroViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/07/2021.
//

import UIKit
import paper_onboarding

struct Fonts {
    static let futuraTitle = UIFont(name: "Futura-Bold", size: 21.0)!
    static let futuraDescription = UIFont(name: "Futura", size: 17.0)!
}

class IntroViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    //Creates different screens of tutorials
    fileprivate let items = [
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "logo"),
                           title: "Welcome to MusicDB!",
                           description: "Here's a short intro on how to use the app.",
                           pageIcon: #imageLiteral(resourceName: "1"),
                           color: UIColor(red: 0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "nav_bar"),
                           title: "Navigation",
                           description: "To navigate between the pages use the bottom navigation bar or by swiping the page.",
                           pageIcon: #imageLiteral(resourceName: "2"),
                           color: UIColor(red: 123.0/255.0, green: 175.0/255.0, blue: 183.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "liked_button"),
                           title: "Liked Tracks",
                           description: "To add/remove tracks from liked tracks, tap the heart icon as shown in the image.",
                           pageIcon: #imageLiteral(resourceName: "3"),
                           color: UIColor(red: 23.0/255.0, green: 42.0/255.0, blue: 58.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "preview_button"),
                           title: "Playing a Preview 1/2",
                           description: "To play a preview, tap the preview button.",
                           pageIcon: #imageLiteral(resourceName: "4"),
                           color: UIColor(red: 227.0/255.0, green: 101.0/255.0, blue: 91.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "play_button_album"),
                           title: "Playing a Preview 2/2",
                           description: "To play a preview, tap the play button.",
                           pageIcon: #imageLiteral(resourceName: "5"),
                           color: UIColor(red: 112.0/255.0, green: 162.0/255.0, blue: 136.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "search"),
                           title: "Searching",
                           description: "To search for any track, just type the track's name.",
                           pageIcon: #imageLiteral(resourceName: "6"),
                           color: UIColor(red: 100.0/255.0, green: 149.0/255.0, blue: 237.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "liked_control"),
                           title: "Switching between Liked Tracks/Albums",
                           description: "To switch between liked tracks and liked albums, tap the control at the top as shown in the image.",
                           pageIcon: #imageLiteral(resourceName: "7"),
                           color: UIColor(red: 176.0/255.0, green: 142.0/255.0, blue: 162.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "intro_end"),
                           title: "Intro's End",
                           description: "I hope this short intro will help you to get started using the app.",
                           pageIcon: #imageLiteral(resourceName: "8"),
                           color: UIColor(red: 239.0/255.0, green: 164.0/255.0, blue: 139.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Fonts.futuraTitle, descriptionFont: Fonts.futuraDescription)
        
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
        
        setupPaperOnboardingView()
        
        view.bringSubviewToFront(doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setupPaperOnboardingView() {
        //Adds the created screens to subview
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)

        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
}

extension IntroViewController {

    @IBAction func doneButtonTapped(_: UIButton) {
        //Saves the value to userdefauls, so the tutorial will appear only once.
        UserDefaults.standard.setIntro(value: true)
        
        let storyboard = UIStoryboard(name: "Login", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
        present(vc, animated: true)
    }
}

extension IntroViewController: PaperOnboardingDelegate {

    //Shows the done button at index 7
    func onboardingWillTransitonToIndex(_ index: Int) {
        doneButton.isHidden = index == 7 ? false : true
    }

    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
        //Resizing the image
        if let imageSize = item.imageView?.image?.size {
            item.informationImageWidthConstraint?.constant = imageSize.width / 2
            item.informationImageHeightConstraint?.constant = imageSize.height / 2
            item.setNeedsUpdateConstraints()
        }
    }
}

extension IntroViewController: PaperOnboardingDataSource {

    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }

    //Returns the number of screens
    func onboardingItemsCount() -> Int {
        return 8
    }
}
