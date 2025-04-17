//
//  Question.swift
//  Romak_C2
//
//  Created by 준호 on 4/14/25.
//

import Foundation
import SwiftData

enum QuestionMode: String, Codable {
    case mentor
    case learner
}

@Model
class Question {
    @Attribute(.unique) var id: Int
    var mode: QuestionMode
    var content: String
    var ratingHistory: [Double]
    var dateAdded: Date

    init(id: Int, mode: QuestionMode, content: String, ratingHistory: [Double] = [], dateAdded: Date = Date()) {
        self.id = id
        self.mode = mode
        self.content = content
        self.ratingHistory = ratingHistory
        self.dateAdded = dateAdded
    }

    var averageRating: Double {
        guard !ratingHistory.isEmpty else { return 0.0 }
        return ratingHistory.reduce(0, +) / Double(ratingHistory.count)
    }
}
