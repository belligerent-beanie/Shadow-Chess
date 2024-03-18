//
//  MyErrors.swift
//  Chess
//
//  Created by arsh-zstch1313 on 27/02/24.
//

import Foundation

struct MyError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}
