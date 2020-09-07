//
//  LoginRequest.swift
//  RxTest
//
//  Created by TOUYA KAWANO on 2020/09/07.
//  Copyright © 2020 Toya Kawano. All rights reserved.
//

import Foundation

struct LoginRequest: HttpRequest {

    typealias Response = LoginResponse
    
    var baseUrl: String { "http://54.250.239.8" }
    
    var path: String { "/login" }
    
    var method: HttpMethod { .post }
            
    struct Request: Encodable {
        let email: String
        let password: String
    }
}

struct LoginResponse: Decodable {
    let status: Int
    let result: User
    
    struct User: Decodable {
        let id: Int
        let email: String
        let token: String
    }
}
