//
//  DropController.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

public struct DropController {
    var collection: [Drop] = []
    var context: NSManagedObjectContext
    
    #if RELEASE_VERSION
        let SERVER_SCHEME = "https"
        let SERVER_HOST = "aiddrop.org"
        let SERVER_PORT = 80
        let SERVER_PATH = "/api/v1/cases"
    #else
        let SERVER_SCHEME = "http"
        let SERVER_HOST = "localhost"
        let SERVER_PORT = 9090
        let SERVER_PATH = "/cases"
    #endif
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
        case empty()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // function to make the network request and populate the collection with managed objects created from the response
    
    func getCases(maxLatitude: Float64,
                  maxLongitude: Float64,
                  minLatitude: Float64,
                  minLongitude: Float64,
                  completion: ((Result<[Drop]>) -> Void)?
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = SERVER_SCHEME
        urlComponents.host = SERVER_HOST
        urlComponents.port = SERVER_PORT
        urlComponents.path = SERVER_PATH
        urlComponents.queryItems = [
            URLQueryItem(name: "maxLatitude", value: "\(maxLatitude)"),
            URLQueryItem(name: "minLatitude", value: "\(minLatitude)"),
            URLQueryItem(name: "maxLongitude", value: "\(maxLongitude)"),
            URLQueryItem(name: "minLongitude", value: "\(minLongitude)"),
        ]
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components: \(urlComponents)")}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                print("Making http call...")
                if let error = error {
                    completion?(.failure(error))
                } else if let jsonData = data {
                    // If the response was empty...
                    if let httpResponse = response as? HTTPURLResponse{
                        if httpResponse.statusCode == 204 {
                            print("No content: 204")
                            completion?(.empty())
                        }
                    }
                
                    // representation of the JSON returned to us
                    // from our URLRequest...
                    
                    // Create an instance of JSONDecoder to decode the JSON data to our
                    // Codable struct
                    let decoder = JSONDecoder()
                    decoder.userInfo[CodingUserInfoKey.context!] = self.context
                    
                    do {
                        // We would use Post.self for JSON representing a single Post
                        // object, and [Post].self for JSON representing an array of
                        // Post objects
                        let drops = try decoder.decode([Drop].self, from: jsonData)
                        completion?(.success(drops))
                    } catch {
                        print("Request failed: \(url)")
                        completion?(.failure(error))
                    }
                
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self,
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = queries.flatMap
            { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}
