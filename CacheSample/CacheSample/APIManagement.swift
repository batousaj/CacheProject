//
//  APIManagement.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 17/09/2022.
//

import Foundation
import UIKit

fileprivate struct Results : Codable {
    let results: [Package.ImageCache]
}

class RequestManager  {
    
    static let sharedInstance = RequestManager()
    
    init() {}
    
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
        let task = URLSession.shared.downloadTask(with: urls) { url, response, error in
            if error != nil {
                successHandler(nil,StatusImage.falied)
                return
            }
            
            guard let response_ = response as? HTTPURLResponse , (200...299).contains(response_.statusCode) else {
                successHandler(nil,StatusImage.falied)
                return
            }
            
            guard let localUrl = url else {
                successHandler(nil, StatusImage.falied)
                return
            }
            
            do {
                let decode = try Data(contentsOf: url!)
                let imageCache = NSCache<NSString,UIImage>()
                let urlStr = localUrl.absoluteString as NSString
                
                if let image = UIImage(data: decode) {
                    imageCache.setObject(image, forKey: urlStr)
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
