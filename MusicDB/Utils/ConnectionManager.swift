//
//  Reachability.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 30/06/2021.
//

import Foundation
import Alamofire

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}
