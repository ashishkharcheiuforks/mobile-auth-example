//
//  AuthNetworkManager.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 3/3/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import Foundation

struct AuthNetworkManager {
    static let environment: NetworkEnvironment = .production
    static let MovieAPIKey = ""
    let router = Router<AuthAPI>()
    
    // MARK: Request Functions
    
    func access(completion: @escaping (_ auth: [AuthAPI]?, _ error: String?) -> ()) {
        router.request(.access) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        saveAuthToken(.access, "jwtAccess")
                        completion(nil, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }

                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func both(completion: @escaping (_ auth: [AuthAPI]?, _ error: String?) -> ()) {
        router.request(.both) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        saveAuthToken(.access, "jwtAccess")
                        saveAuthToken(.refresh, "jwtRefresh")
                        completion(nil, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }

                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
}