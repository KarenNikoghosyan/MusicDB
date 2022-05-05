//
//  DetailsMusicViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 20/06/2021.
//

import UIKit
import SDWebImage
import SafariServices
import Loady
import ViewAnimator
import WCLShineButton
import Loaf
import MarqueeLabel

class DetailsMusicViewController: BaseViewController {
    
    let detailsMusicViewModel = DetailsMusicViewModel()

    private var prevButton: UIButton = UIButton()
    private let noTracksLabel = UILabel()
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var artistTableView: UITableView!
    @IBOutlet private weak var detailsImageView: UIImageView!
    @IBOutlet private weak var detailsArtistNameLabel: MarqueeLabel!
    @IBOutlet private weak var detailsAlbumTitleLabel: MarqueeLabel!
    @IBOutlet private weak var detailsDurationLabel: MarqueeLabel!
    @IBOutlet private weak var goToWebsiteButton: UIButton!
    @IBOutlet private weak var previewButton: LoadyButton!
    @IBOutlet private weak var likedButton: WCLShineButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Checks the connectivity status
        if Connectivity.isConnectedToInternet {
            detailsMusicViewModel.fetchTracks()
            detailsMusicViewModel.checkLikedStatus()
            setupActivityIndicator()
            detailsMusicViewModel.setupBaseObservers()
        }
        
        setupTitle()
        setupLabels()
        setupLikeButton()
        setupNoTracksLabel()
        setupDelegates()
     
        guard let isAlbumDetails = detailsMusicViewModel.isAlbumDetails else {return}
        if !isAlbumDetails {
            setUpViewsFromTrack()
        } else {
            setUpViewsFromAlbumDetails()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Connectivity.isConnectedToInternet {
            showAlertAndReload(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
        }
    }
    
    //Stops the audio from playing when the app moves to the background
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if navigationController?.isBeingDismissed ?? false {
            stopAudio()
            NotificationCenter.default.post(name: .ResetPlayButton, object: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.orientation.isLandscape {
            setupLandscapeConstraints()
        } else {
            setupPortraitConstraints()
        }
    }
    
    @IBAction private func backButtonTapped(_ sender: UIBarButtonItem) {
        stopAudio()
        Loaf.dismiss(sender: self, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func goToWebsiteTapped(_ sender: UIButton) {
        Loaf.dismiss(sender: self, animated: true)
        
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.4), for: .normal)
            self?.goToWebsiteButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        
        guard let track = detailsMusicViewModel.track,
              let url = URL(string: "\(track.link ?? detailsMusicViewModel.cantLoadLinkText)") else {return}
        
        let sfVC = SFSafariViewController(url: url)
        present(sfVC, animated: true)
        stopAudio()
    }
    
    @IBAction private func likedButtonTapped(_ sender: WCLShineButton) {
        detailsMusicViewModel.toggleLikedButton()
    }
    
    @IBAction private func animateButton(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        
        //If a track is already playing, tapping for the second time will make the button to stop animating
        if let button = sender as? LoadyButton {
            if button.loadingIsShowing() {
                stopAudio()
                return
            }
            //Starts the button animation
            button.startLoading()
            button.setImage(UIImage(systemName: detailsMusicViewModel.pauseCircleImage), for: .normal)
            guard let str = detailsMusicViewModel.track?.preview,
                  let url = URL(string: str) else {return}
            NotificationCenter.default.post(name: .ResetPlayButton, object: nil)
            MediaPlayer.shared.loadAudio(url: url)
        }
    }

    @IBAction private func playButtonTapped(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        detailsMusicViewModel.playButtonLogic(sender)
    }
}

//MARK: - Functions
extension DetailsMusicViewController {
    
    private func setupDelegates() {
        MediaPlayer.shared.delegate = self
        detailsMusicViewModel.delegate = self
        artistTableView.delegate = self
        artistTableView.dataSource = self
    }
    
    //Checks the current running device and loads the appropriate constraints based on the device.
    //potrait orientation
    private func setupPortraitConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 130
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 150
        case .iPhone8:
            imageViewHeightConstraint.constant = 150
        default:
            break
        }
    }
    
    //landscape orientation
    private func setupLandscapeConstraints() {
        switch UIDevice().type {
        case .iPod7:
            imageViewHeightConstraint.constant = 100
        case .iPhoneSE2:
            imageViewHeightConstraint.constant = 100
        case .iPhone8:
            imageViewHeightConstraint.constant = 100
        default:
            break
        }
    }
    
    private func setupTitle() {
        self.title = detailsMusicViewModel.track?.titleShort
    }
    
    private func setupLabels() {
        detailsArtistNameLabel.animationCurve = .linear
        detailsAlbumTitleLabel.animationCurve = .linear
        detailsDurationLabel.animationCurve = .linear
    }
    
    //Sets up the views
    private func setUpViewsFromTrack() {
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let track = detailsMusicViewModel.track,
              let url = URL(string: "\(track.album?.coverMedium ?? "")") else {
            
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 25
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.layer.cornerRadius = 25
        detailsImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsImageView.sd_setImage(with: url)
        
        detailsArtistNameLabel.text = track.artist.name
        detailsAlbumTitleLabel.text = track.album?.title
        
        detailsDurationLabel.text = "\(detailsMusicViewModel.getMinutesAndSeconds().0):\(detailsMusicViewModel.getMinutesAndSeconds().1)"
    }
    
    //Sets up the views if we came from the albums screen/viewcontroller
    private func setUpViewsFromAlbumDetails() {
        self.previewButton.addTarget(self, action: #selector(animateButton(_:)), for: .touchUpInside)
        
        self.previewButton.setAnimation(LoadyAnimationType.android())
        
        guard let album = detailsMusicViewModel.album,
              let url = URL(string: "\(album.coverMedium ?? "")") else {
            
            detailsImageView.tintColor = .white
            detailsImageView.image = #imageLiteral(resourceName: "No_Photo_Available")
            detailsImageView.layer.cornerRadius = 25
            return
        }
        
        detailsImageView.tintColor = .white
        detailsImageView.layer.cornerRadius = 25
        detailsImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        detailsImageView.sd_setImage(with: url)
        
        detailsArtistNameLabel.text = detailsMusicViewModel.track?.artist.name
        detailsAlbumTitleLabel.text = detailsMusicViewModel.album?.title
        
        detailsDurationLabel.text = "\(detailsMusicViewModel.getMinutesAndSeconds().0):\(detailsMusicViewModel.getMinutesAndSeconds().1)"
    }
    
    //Creates the liked button
    private func setupLikeButton() {
        var param = WCLShineParams()
        param.bigShineColor = UIColor(rgb: (153,152,38))
        param.smallShineColor = UIColor(rgb: (102,102,102))
        
        likedButton.image = .heart
        
        likedButton.fillColor = UIColor(rgb: (255,0,0))
        likedButton.color = UIColor(rgb: (100,100,100))
    }
    
    private func setupNoTracksLabel() {
        noTracksLabel.text = detailsMusicViewModel.noTracksFoundText
        noTracksLabel.font = UIFont.init(name: Constants.futura, size: 20)
        noTracksLabel.textColor = .white
        noTracksLabel.textAlignment = .center
        
        view.addSubview(noTracksLabel)
        
        noTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noTracksLabel.topAnchor.constraint(equalTo: artistTableView.topAnchor, constant: 24),
            noTracksLabel.leadingAnchor.constraint(equalTo: artistTableView.leadingAnchor, constant: 0),
            noTracksLabel.trailingAnchor.constraint(equalTo: artistTableView.trailingAnchor, constant: 0)
        ])
        noTracksLabel.isHidden = true
    }
    
    override func setupActivityIndicator() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: artistTableView.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: artistTableView.centerXAnchor)
        ])
        
        activityIndicatorView.startAnimating()
    }
    
    private func stopAudio() {
        MediaPlayer.shared.stopAudio()
        
        previewButton.stopLoading()
        previewButton.setImage(UIImage(systemName: detailsMusicViewModel.playCircleImage), for: .normal)
        
        prevButton.setImage(UIImage(systemName: Constants.playFillText), for: .normal)
        detailsMusicViewModel.arrIndexPaths.removeAll()
        if let prevIndexPath = detailsMusicViewModel.prevIndexPath {
            artistTableView.reloadRows(at: [prevIndexPath], with: .none)
        }
    }
    
    private func showAlertAndReload(title: String? = nil, message: String? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        vc.addAction(.init(title: Constants.retryText, style: .cancel, handler: {[weak self] action in
            guard let self = self else {return}
            
            if !Connectivity.isConnectedToInternet {
                self.showAlertAndReload(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            } else {
                self.detailsMusicViewModel.fetchTracks()
                self.detailsMusicViewModel.checkLikedStatus()
                self.setupActivityIndicator()
            }
        }))
        present(vc, animated: true)
    }
}

//MARK: - UITableView Functions
extension DetailsMusicViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Loaf.dismiss(sender: self, animated: true)
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        let parentVC = presentingViewController
            
        dismiss(animated: true) {[weak self] in
            guard let self = self,
                  let detailsVC = DetailsMusicViewController.storyboardInstance(storyboardID: self.detailsMusicViewModel.storyboardID, restorationID: self.detailsMusicViewModel.storyboardRestorationID) as? UINavigationController,
                  let targetController = detailsVC.topViewController as? DetailsMusicViewController else {return}
            
            self.stopAudio()
            let track = self.detailsMusicViewModel.tracks[indexPath.row]
            targetController.detailsMusicViewModel.track = track
            parentVC?.present(detailsVC, animated: true)
        }
    }
}

//MARK: - DataSources
extension DetailsMusicViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsMusicViewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! DetailsTableViewCell
        cell.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)

        cell.playButton.tag = indexPath.row
        
        if detailsMusicViewModel.arrIndexPaths.contains(indexPath) {
            cell.playButton.setImage(UIImage(systemName: Constants.pauseFillImage), for: .normal)
            cell.playButton.tintColor = .white
        } else {
            cell.playButton.setImage(UIImage(systemName: Constants.playFillImage), for: .normal)
            cell.playButton.tintColor = .darkGray
        }
        
        cell.populateTrack(track: detailsMusicViewModel.tracks[indexPath.row])
        return cell
    }
}

//MARK: - Delegates
extension DetailsMusicViewController: DetailsMusicViewModelDelegate {
    func reloadTableViewRows(selectedIndexPath: IndexPath) {
        artistTableView.reloadRows(at: [selectedIndexPath], with: .none)
    }
    
    func reloadTableView() {
        self.artistTableView.reloadData()
    }
    
    func animateTableViewCells() {
        let cells = self.artistTableView.visibleCells
        UIView.animate(views: cells, animations: [self.animation])
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func isNoTracksLabelHidden(isHidden: Bool) {
        self.noTracksLabel.isHidden = isHidden
    }
    
    func assignPrevButton(_ sender: UIButton) {
        prevButton = sender
    }
    
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath) {
        prevButton.setImage(UIImage(systemName: Constants.playFillImage), for: .normal)
        artistTableView.reloadRows(at: [prevIndexPath], with: .none)
    }
    
    func changePreviewButtonState() {
        self.previewButton.stopLoading()
        self.previewButton.setImage(UIImage(systemName: detailsMusicViewModel.playCircleImage), for: .normal)
    }
    
    func isLikedButtonSelected(isSelected: Bool) {
        likedButton.isSelected = isSelected
    }
    
    func stopAudioPlaying() {
        stopAudio()
    }
    
    func showAlertPopup() {
        showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
    }
    
    func loafMessageWasAdded(track: Track) {
        loafMessageAdded(track: track)
    }
    
    func loafMessageWasRemoved(track: Track) {
        loafMessageRemoved(track: track)
    }
}

extension DetailsMusicViewController: MediaPlayerDelegate {
    func changeButtonStateAfterAudioStopsPlaying() {
        detailsMusicViewModel.changeButtonStateAfterAudioStopsPlaying()
        
        if previewButton.loadingIsShowing() {
            previewButton.stopLoading()
            previewButton.setImage(UIImage(systemName: detailsMusicViewModel.playCircleImage), for: .normal)
        }
    }
}
