//
//  APIContent.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import Foundation

enum APIContent: Decodable, Identifiable {
    case book(BookInfo)
    case list(ListInfo)
    
    struct BookInfo: Codable {
        var title: String
        var subtitle: String?
        var url: String
    }

    struct ListInfo: Codable {
        var title: String
        var subtitle: String?
        var url: String
    }
    
    var id: String {
        switch self {
        case .book(let book):
            return "book." + book.url
        case .list(let list):
            return "list." + list.url
        }
    }
    
    enum CodingKeys: CodingKey {
        case book
        case list
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<APIContent.CodingKeys> = try decoder.container(keyedBy: APIContent.CodingKeys.self)
        
        var allKeys: ArraySlice<APIContent.CodingKeys> = ArraySlice<APIContent.CodingKeys>(container.allKeys)
        
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(APIContent.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .book:
            self = APIContent.book(try container.decode(BookInfo.self, forKey: CodingKeys.book))
        case .list:
            self = APIContent.list(try container.decode(ListInfo.self, forKey: CodingKeys.list))
        }
    }
}
