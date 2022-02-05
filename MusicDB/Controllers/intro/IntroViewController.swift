//
//  IntroViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/07/2021.
//

import UIKit
import paper_onboarding

class IntroViewController: UIViewController {
    
    private let viewModel = IntroViewModel()
    
    @IBOutlet weak var doneButton: UIButton!
    
    //Creates different screens of tutorials
    fileprivate lazy var items = [
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "logo"),
                           title: viewModel.firstScreenTitle,
                           description: viewModel.firstScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "1"),
                           color: UIColor(red: 0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "nav_bar"),
                           title: viewModel.secondScreenTitle,
                           description: viewModel.secondScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "2"),
                           color: UIColor(red: 123.0/255.0, green: 175.0/255.0, blue: 183.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "liked_button"),
                           title: viewModel.thirdScreenTitle,
                           description: viewModel.secondScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "3"),
                           color: UIColor(red: 23.0/255.0, green: 42.0/255.0, blue: 58.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "preview_button"),
                           title: viewModel.fourthScreenTitle,
                           description: viewModel.fourthScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "4"),
                           color: UIColor(red: 227.0/255.0, green: 101.0/255.0, blue: 91.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "play_button_album"),
                           title: viewModel.fifthScreenTitle,
                           description: viewModel.fifthScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "5"),
                           color: UIColor(red: 112.0/255.0, green: 162.0/255.0, blue: 136.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "search"),
                           title: viewModel.sixthScreenTitle,
                           description: viewModel.sixthScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "6"),
                           color: UIColor(red: 100.0/255.0, green: 149.0/255.0, blue: 237.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "liked_control"),
                           title: viewModel.seventhScreenTitle,
                           description: viewModel.secondScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "7"),
                           color: UIColor(red: 176.0/255.0, green: 142.0/255.0, blue: 162.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription),
        
        OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "intro_end"),
                           title: viewModel.eighthScreenTitle,
                           description: viewModel.eighthScreenDescription,
                           pageIcon: #imageLiteral(resourceName: "8"),
                           color: UIColor(red: 239.0/255.0, green: 164.0/255.0, blue: 139.0/255.0, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: Constants.Fonts.futuraTitle, descriptionFont: Constants.Fonts.futuraDescription)
        
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
        
        setupPaperOnboardingView()
        
        view.bringSubviewToFront(doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
}

//MARK: - Functions
extension IntroViewController {
    
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

    @IBAction func doneButtonTapped(_: UIButton) {
        //Saves the value to userdefauls, so the tutorial will appear only once.
        UserDefaults.standard.setIntro(value: true)
        
        let storyboard = UIStoryboard(name: viewModel.storyBoardName, bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: viewModel.storyBoardIdentifier)
        present(vc, animated: true)
    }
}

//MARK: - Delegates
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
