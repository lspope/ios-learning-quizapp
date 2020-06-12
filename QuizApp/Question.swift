//
//  Question.swift
//  QuizApp
//
//  Created by Leah Pope on 4/27/20.
//  Copyright © 2020 lsp. All rights reserved.
//

import Foundation

struct Question: Codable {
    
    var question:String?
    var answers:[String]?
    var correctAnswerIndex:Int?
    var feedback:String?
}
