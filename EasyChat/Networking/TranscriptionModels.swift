//
//  TranscriptionModels.swift
//  EasyChat
//
//  Created by Talha Çelebi on 26.12.2025.
//

import Foundation

struct TranscriptionResponse: Codable {
    let status: String
    let speakers: [Speaker]?
    let message: String?
}

struct Speaker: Codable {
    let speaker: String
    let text: String
    let start: Double
    let end: Double
}


