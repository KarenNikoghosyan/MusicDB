//
//  SingleAlbumAPIDataSource.swift
//  MusicDB
//
//  Created by Karen Nikoghosyan on 29/07/2021.
//

import Foundation

struct SingleAlbumAPIDataSource {
    private static let baseURL = "https://api.deezer.com"
    
    enum EndPoint: String {
        case album = "/album"
    }
    
    func fetchAlbums(from endpoint: EndPoint, id: Int?, callback: @escaping SingleAlbumDSCallback) {
        var urlComponents = URLComponents(string: SingleAlbumAPIDataSource.baseURL)
        
        urlComponents?.path = endpoint.rawValue + "/\(id ?? 0)"
        
        guard let url = urlComponents?.url else {
            callback(nil, .invalidURL(url: urlComponents))
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: url) { data, response, error in
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
                let result = try JSONDecoder().decode(TopAlbums.self, from: data)
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

typealias SingleAlbumDSCallback = (TopAlbums?, _ error: SingleAlbumAPIDataSourceError?)->Void

enum SingleAlbumAPIDataSourceError: Error {
    case invalidURL(url: URLComponents?)
    case connectionFailed(cause: Error?)
    case jsonDecodingFailed(cause: Error)
    case codeError(code: Int)
    case noData
}
