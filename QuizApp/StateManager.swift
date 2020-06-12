//
//  StateManager.swift
//  QuizApp
//
//  Created by Leah Pope on 4/29/20.
//  Copyright © 2020 lsp. All rights reserved.
//

import Foundation

class StateManager {
    
    static var numCorrectKey = "NumCorrectKey"
    static var questionIndexKey = "QuestionIndexKey"
    
    static func saveState(numCorrect: Int, questionIndex: Int) {
        let defaults = UserDefaults.standard
        defaults.set(numCorrect, forKey: numCorrectKey)
        defaults.set(questionIndex, forKey: questionIndexKey)
    }
    
    static func retrieveValue(key: String) -> Any? {
        let defaults = UserDefaults.standard
        return defaults.value(forKey: key)
    }
    
    static func clearState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: numCorrectKey)
        defaults.removeObject(forKey: questionIndexKey)
    }
    
}
