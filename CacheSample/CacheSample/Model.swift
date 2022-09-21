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

enum OptionsWrite  {
    case kWithoutOverwrite
    case kOverwrite
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
    
    struct ImageCache : Decodable {
        var id = ""
        var alt_description = ""
        var user : UserRequest
        var urls : CollectionImage
        
        enum CodingKeys : String, CodingKey {
            case id
            case alt_description
            case user
            case urls
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(String.self, forKey: .id)
            self.alt_description = try container.decode(String.self, forKey: .alt_description)
            self.user = try container.decode(UserRequest.self, forKey: .user)
            self.urls = try container.decode(CollectionImage.self, forKey: .urls)
        }
    }
    
    struct UserRequest : Decodable {
        let id : String
        let name : String
        let profile_image : UserProfileImage
        
        enum CodingKeys : String, CodingKey {
            case id
            case name
            case profile_image
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.profile_image = try container.decode(UserProfileImage.self, forKey: .profile_image)
        }

    }
    
    struct UserProfileImage : Decodable {
        var small : String
        var medium : String
        var large : String
        
        enum CodingKeys : String, CodingKey {
            case small
            case medium
            case large
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.small = try container.decode(String.self, forKey: .small)
            self.medium = try container.decode(String.self, forKey: .medium)
            self.large = try container.decode(String.self, forKey: .large)
        }
    }
    
    struct CollectionImage : Decodable {
        var raw : String
        var full :String
        var regular : String
        var small : String
        var thumb : String
        
        enum CodingKeys : String, CodingKey {
            case raw
            case full
            case regular
            case small
            case thumb
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.raw = try container.decode(String.self, forKey: .raw)
            self.full = try container.decode(String.self, forKey: .full)
            self.regular = try container.decode(String.self, forKey: .regular)
            self.small = try container.decode(String.self, forKey: .small)
            self.thumb = try container.decode(String.self, forKey: .thumb)
        }
    }
}
