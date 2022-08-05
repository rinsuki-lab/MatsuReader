//
//  APIBook.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import Foundation

struct APIBook: Decodable {
    var pages: [Page]
    
    struct Page: Decodable, Identifiable {
        var url: String
        var width: Int
        var height: Int
        
        var id: String { url }
    }
}
