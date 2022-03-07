//
//  BaseTableViewController.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 19/07/2021.
//

import UIKit
import NVActivityIndicatorView
import ViewAnimator
import SafariServices
import Loaf

class BaseTableViewController: UIViewController {
    
    let baseViewModel = BaseTableViewModel()
    
    var tableView = UITableView()
    var prevButton: UIButton = UIButton()
    
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .systemGreen, padding: 0)
    let animation = AnimationType.from(direction: .right, offset: 30.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseViewModel.delegate = self
        MediaPlayer.shared.delegate = self
        
        setupObservers()
    }

    @IBAction func btnTapped(_ sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        playButtonLogic(sender)
    }
}

//MARK: - Functions
extension BaseTableViewController {
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .ResetPlayButton, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            self.baseViewModel.resetPlayButton()
        }
    }
    
    private func playButtonLogic(_ sender: UIButton) {
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        
        //Resets the play button state
        if baseViewModel.arrIndexPaths.contains(selectedIndexPath) {
            baseViewModel.clearArrIndexPath()
            sender.setImage(UIImage(systemName: baseViewModel.playFillImage), for: .normal)
            sender.tintColor = .darkGray
            
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
            MediaPlayer.shared.stopAudio()
            return
        }
        
        //If we tapping on a second button it will reset the state of the previous button
        if baseViewModel.arrIndexPaths.count == 1 {
            baseViewModel.resetPlayButton()
        }
        
        //Saves the previous index and the button
        baseViewModel.prevIndexPath = selectedIndexPath
        prevButton = sender
        baseViewModel.arrIndexPaths.append(selectedIndexPath)
        tableView.reloadRows(at: [selectedIndexPath], with: .none)
        
        //Plays the albums tracks if we came from the albums screen
        baseViewModel.playTrackIfFromAlbumsScreen(selectedIndexPath: selectedIndexPath)
        
        //Plays the tracks if we came from other screens
        baseViewModel.playTrackIfOtherScreen(selectedIndexPath: selectedIndexPath)
    }
    
    @objc func loadActivityIndicator() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicatorView.startAnimating()
    }

    
    //Changes the style of the accesssory arrow
    func accessoryArrow(cell: UITableViewCell) {
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessoryView = UIImageView(image: UIImage(systemName: baseViewModel.chevronRightImage))
        cell.tintColor = .white
    }
    
    func openWebsite(albums: [TopAlbums], sender: UIButton) {
        if !Connectivity.isConnectedToInternet {
            showViewControllerAlert(title: Constants.noInternetConnectionText, message: Constants.failedToConnectText)
            return
        }
        let selectedIndexPath = IndexPath.init(row: sender.tag, section: 0)
        let album = albums[selectedIndexPath.row]
        
        guard let url = URL(string: "\(album.link)") else {return}
        let sfVC = SFSafariViewController(url: url)
        Loaf.dismiss(sender: self, animated: true)
        self.present(sfVC, animated: true)
    }
    
    //Populates the cell based on the current active ViewController
    func populateCell(indexPath: IndexPath, cell: DetailsTableViewCell, tableView: UITableView) {
        
        self.tableView = tableView
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
        
        if baseViewModel.arrIndexPaths.contains(indexPath) {
            cell.playButton.setImage(UIImage(systemName: baseViewModel.pauseFillImage), for: .normal)
            cell.playButton.tintColor = .white
        } else {
            cell.playButton.setImage(UIImage(systemName: baseViewModel.playFillImage), for: .normal)
            cell.playButton.tintColor = .darkGray
        }
    }
}

//MARK: - Delegates
extension BaseTableViewController: UITableViewDelegate {
    
    //Adds and highlighted effect when tapping on a cell
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = tableView.cellForRow(at: indexPath) as? LikedGenreTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumsTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            } else if let cell = tableView.cellForRow(at: indexPath) as? SearchMusicTableViewCell {
                cell.contentView.backgroundColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
            }
        }
    }
    
    //Adds and unhighlighted effect when releasing a cell
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            if let cell = tableView.cellForRow(at: indexPath) as? LikedGenreTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumsTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? DetailsTableViewCell {
                cell.contentView.backgroundColor = .clear
            } else if let cell = tableView.cellForRow(at: indexPath) as? SearchMusicTableViewCell {
                cell.contentView.backgroundColor = .clear
            }
        }
    }
}

extension BaseTableViewController: BaseTableViewModelDelegate {
    func changeButtonImageAndReloadRows(prevIndexPath: IndexPath) {
        
        self.prevButton.setImage(UIImage(systemName: self.baseViewModel.playFillImage), for: .normal)
        self.tableView.reloadRows(at: [prevIndexPath], with: .none)
    } 
}

extension BaseTableViewController: MediaPlayerDelegate {
    func changeButtonStateAfterAudioStopsPlaying() {
        baseViewModel.changeButtonStateAfterAudioStopsPlaying()
    }
}
