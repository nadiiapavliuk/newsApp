//
//  NewsModel.swift
//  News
//
//  Created by Nadiia Pavliuk on 3/30/18.
//  Copyright © 2018 Nadiia Pavliuk. All rights reserved.
//

import Foundation



class News: Codable {
    //    let status: String
    //    let totalResults: Int
    let articles: [Article]
    
    init(articles: [Article]) {
        //        self.status = status
        //        self.totalResults = totalResults
        self.articles = articles
    }
}

//class Source: Codable {
//    let name: String
//    init(name: String) {
//        self.name = name
//    }
//}

class Article: Codable {
    let author: String?
    let publishedAt: String
    let title: String
    let description: String
    let urlToImage: String
    let url: String
    
    init(author: String?, publishedAt: String, title: String, description: String, urlToImage: String, url: String) {
       
        self.author = author
        self.publishedAt = publishedAt
        self.title = title
        self.description = description
        self.urlToImage = urlToImage
        self.url = url
    }
}


