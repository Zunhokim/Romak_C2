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
    case runner
}

@Model
class Question {
    @Attribute(.unique) var id: Int
    var mode: QuestionMode
    var content: String
    var rating: Double
    var dateAdded: Date

    init(id: Int, mode: QuestionMode, content: String, rating: Double = 0.0, dateAdded: Date = Date()) {
        self.id = id
        self.mode = mode
        self.content = content
        self.rating = rating
        self.dateAdded = dateAdded
    }
}
