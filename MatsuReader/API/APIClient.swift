//
//  APIClient.swift
//  MatsuReader
//
//  Created by user on 2022/08/03.
//

import Foundation
import SwiftUI

class APIClient {
    var url: URL
    var headers: [String: String]
    
    enum ClientError: Error {
        case serverError(code: Int, message: String)
    }
    
    init?(account: Account) {
        url = account.url!
        if let userName = account.userName {
            // auth required
            guard let password = try? account.getPassword() else {
                return nil
            }
            headers = [
                "Authorization": "Basic " + (userName + ":" + password).data(using: .utf8)!.base64EncodedString(),
            ]
        } else {
            headers = [:]
        }
    }
    
    func getContents(path: String) async throws -> [APIContent] {
        let url: URL
        if path.count > 0 {
            url = .init(string: path, relativeTo: self.url)!
        } else {
            url = self.url
        }
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            preconditionFailure()
        }
        if response.statusCode >= 400 {
            throw ClientError.serverError(code: response.statusCode, message: String(data: data, encoding: .utf8)!)
        }
        let decoder = JSONDecoder()
        let contents = try decoder.decode([APIContent].self, from: data)
        return contents
    }
    
    func getBook(path: String) async throws -> APIBook {
        let url: URL
        if path.count > 0 {
            url = .init(string: path, relativeTo: self.url)!
        } else {
            url = self.url
        }
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            preconditionFailure()
        }
        if response.statusCode >= 400 {
            throw ClientError.serverError(code: response.statusCode, message: String(data: data, encoding: .utf8)!)
        }
        let decoder = JSONDecoder()
        let contents = try decoder.decode(APIBook.self, from: data)
        return contents
    }
    
    func getImage(path: String) async throws -> Image {
        let url: URL
        if path.count > 0 {
            url = .init(string: path, relativeTo: self.url)!
        } else {
            url = self.url
        }
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            preconditionFailure()
        }
        if response.statusCode >= 400 {
            throw ClientError.serverError(code: response.statusCode, message: String(data: data, encoding: .utf8)!)
        }
        
        return Image(uiImage: .init(data: data)!)
    }
}
