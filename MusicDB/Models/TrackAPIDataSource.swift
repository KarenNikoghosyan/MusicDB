//
//  TrackAPIDataSource.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 18/06/2021.
//

import Foundation

struct TrackAPIDataSource {
    private static let baseURL = "https://api.deezer.com"
    
    enum EndPoint: String {
        case search = "/search"
    }
    
    func fetchTrucks(from endpoint: EndPoint, with params: [String:Any], callback: @escaping TrackDSCallback) {
        var urlComponents = URLComponents(string: TrackAPIDataSource.baseURL)
        urlComponents?.path = endpoint.rawValue
        
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
                let result = try JSONDecoder().decode(TracksAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    callback(result.data, nil)
                }
            } catch let error{
                DispatchQueue.main.async {
                    callback(nil, .jsonDecodingFailed(cause: error))
                }
            }
            
        }.resume()
    }
    
}

typealias TrackDSCallback = ([Track]?, _ error: TrackAPIDataSourceError?)->Void

enum TrackAPIDataSourceError: Error {
    case invalidURL(url: URLComponents?)
    case connectionFailed(cause: Error?)
    case jsonDecodingFailed(cause: Error)
    case codeError(code: Int)
    case noData
}
