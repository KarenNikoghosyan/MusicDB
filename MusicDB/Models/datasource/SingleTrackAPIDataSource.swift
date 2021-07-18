//
//  SingleTrackAPIDataSource.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 09/07/2021.
//

import Foundation

struct SingleTrackAPIDataSource {
    private static let baseURL = "https://api.deezer.com"
    
    enum EndPoint: String {
        case track = "/track"
    }
    
    func fetchTracks(from endpoint: EndPoint, id: Int?, with params: [String:Any], callback: @escaping SingleTrackDSCallback) {
        var urlComponents = URLComponents(string: SingleTrackAPIDataSource.baseURL)
        
        urlComponents?.path = endpoint.rawValue + "/\(id ?? 0)"
        
        let params = params
        var queryItems: [URLQueryItem] = []
        for(key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            callback(nil, .invalidURL(url: urlComponents))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    DispatchQueue.main.async {
                        callback(nil, .codeError(code: response.statusCode))
                    }
                    return
                }
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    callback(nil, .connectionFailed(cause: error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    callback(nil, .noData)
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Track.self, from: data)
                DispatchQueue.main.async {
                    callback(result, nil)
                }
            } catch let error{
                DispatchQueue.main.async {
                    callback(nil, .jsonDecodingFailed(cause: error))
                }
            }
            
        }.resume()
    }
}

typealias SingleTrackDSCallback = (Track?, _ error: SingleTrackAPIDataSourceError?)->Void

enum SingleTrackAPIDataSourceError: Error {
    case invalidURL(url: URLComponents?)
    case connectionFailed(cause: Error?)
    case jsonDecodingFailed(cause: Error)
    case codeError(code: Int)
    case noData
}
