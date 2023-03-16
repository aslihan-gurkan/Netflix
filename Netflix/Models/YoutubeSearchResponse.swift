//
//  YoutubeSearchResponse.swift
//  Netflix
//
//  Created by Aslıhan Gürkan on 23.02.2023.
//

import Foundation

struct YoutubeSearchResponse : Codable {
    let items : [VideoItem]
}

struct VideoItem : Codable {
    let kind : String
    let etag : String
    let id : VideoIdItem
}

struct VideoIdItem : Codable {
    let kind : String
    let videoId : String
}
