//
//  AlbumTrackAPIDataSource.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 27/07/2021.
//

import Foundation

struct AlbumTrackAPIDataSource {
    private static let baseURL = "https://api.deezer.com"
    
    enum EndPoint: String {
        case album = "/album"
    }
    
    func fetchTracks(from endpoint: EndPoint, path: String? ,with params: [String:Any], callback: @escaping AlbumTrackDSCallback) {
        var urlComponents = URLComponents(string: AlbumTrackAPIDataSource.baseURL)
        
        urlComponents?.path = endpoint.rawValue + "\(path ?? "")"
        
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
                let result = try JSONDecoder().decode(AlbumTracksAPIResponse.self, from: data)
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

typealias AlbumTrackDSCallback = ([AlbumTrack]?, _ error: AlbumTrackAPIDataSourceError?)->Void

enum AlbumTrackAPIDataSourceError: Error {
    case invalidURL(url: URLComponents?)
    case connectionFailed(cause: Error?)
    case jsonDecodingFailed(cause: Error)
    case codeError(code: Int)
    case noData
}
