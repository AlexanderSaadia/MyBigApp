//
//  Activity.swift
//  MyBigApp
//
//  Created by Gemini CLI on 08/05/26.
//

import Foundation

struct Activity: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var symbol: String
    var notes: String = ""
    
    // MARK: - Stored properties
}
