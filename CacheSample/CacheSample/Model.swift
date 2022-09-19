//
//  Model.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 19/09/2022.
//

import Foundation
import UIKit

let ACCESS_TOKEN = "3d6Sv6TrqmMWHalTtNqv_gcVy-lNB1Oaoe32-Tkxv0I"

enum Status : Error {
    case OK
    case badRequest
    case badResponse
    case requestFailed
}

enum StatusImage : Error {
    case success
    case falied
}

class Package {
    /*
     http://user:Password@example.com:8000/over/there/text.dtb?type=animal&name=narwhal#nose
     scheme = http
     user = user
     password = Password
     host = example.com
     port = 8000
     path = over/there/text
     extension = dtb
     query = type=animal&name=narwhal
     fragment = nose
     */
    static func componentURI() -> URLComponents {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.unsplash.com"
        return component
    }
    
    struct ImageCache : Codable {
        let id : String
        let description : String
        let user : UserRequest
        let urls : CollectionImage
    }
    
    struct UserRequest : Codable {
//        let id : String
//        let name : String
        let profile_image : UserProfileImage
    }
    
    struct UserProfileImage : Codable {
//        let small : String
        let medium : String
//        let large : String
    }
    
    struct CollectionImage : Codable {
//        let raw : String
//        let full :String
        let regular : String
//        let small : String
//        let thumb : String
    }
}
