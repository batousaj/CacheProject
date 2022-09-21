//
//  APIManagement.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 17/09/2022.
//

import Foundation
import UIKit

fileprivate struct Results : Decodable {
    var results: [Package.ImageCache]?
    
    enum CodingKeys : String, CodingKey {
        case results
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.results = try container.decode([Package.ImageCache].self, forKey: .results)
    }
}

class RequestManager  {
    
    static let sharedInstance = RequestManager()
    
    var imageCache = CacheManagers<String,Data>.init(countLimit: 20) {
        return Date.init()
    }
    
    init() {
//        imageCache.countLimit = 20
    }
    
    private func request(URLs : URL) -> URLRequest? {
        var request = URLRequest(url: URLs)
        request.addValue("Client-ID \(ACCESS_TOKEN)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func requestSearchImageList(query : String, successHandler:@escaping ([Package.ImageCache]?, Error?)-> Void ) {
        var component = Package.componentURI()
        component.path = "/search/photos"
        component.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        if (component.url != nil) {
            if let request = self.request(URLs: component.url!) {
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        successHandler(nil,Status.requestFailed)
                        return
                    }
                    
                    guard let response_ = response as? HTTPURLResponse, (200...299).contains(response_.statusCode) else {
                        successHandler(nil,Status.badResponse)
                        return
                    }
                    
                    do {
                        let decode = try JSONDecoder().decode(Results.self, from: data!)
                        successHandler(decode.results, nil)
                    } catch {
                        successHandler(nil, Status.badResponse)
                    }
                }
                task.resume()
            } else {
                successHandler(nil, Status.badRequest)
            }
            return
        }
        successHandler(nil, Status.requestFailed)
    }
    
    func downloadImage(_ urls: URL, successHandler:@escaping (UIImage?, Error?)-> Void ) {
        if imageCache.valueForKey( urls.absoluteString) != nil {
            print("Image was state in cache")
            return;
        }
        let task = URLSession.shared.downloadTask(with: urls) { url, response, error in
            if error != nil {
                successHandler(nil,StatusImage.falied)
                return
            }
            
            guard let response_ = response as? HTTPURLResponse , (200...299).contains(response_.statusCode) else {
                successHandler(nil,StatusImage.falied)
                return
            }
            
            guard url != nil else {
                successHandler(nil, StatusImage.falied)
                return
            }
            
            do {
                let decode = try Data(contentsOf: url!)
                let urlStr = urls.absoluteString
                self.imageCache.insertValue(decode, forKey: urlStr)
                
                if let image = UIImage(data: decode) {
                    print("Save cache Image")
                    successHandler(image, nil)
                }
            } catch {
                successHandler(nil, StatusImage.falied)
                return
            }
        }
        task.resume()
    }
    
}
