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

class BaseViewController: UIViewController {
    
    let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .systemGreen, padding: 0)
    let animation = AnimationType.from(direction: .right, offset: 30.0)
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - Functions
extension BaseViewController {

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
        cell.accessoryView = UIImageView(image: UIImage(systemName: Constants.chevronRightImage))
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
}

//MARK: - Delegates
extension BaseViewController: UITableViewDelegate {
    
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
