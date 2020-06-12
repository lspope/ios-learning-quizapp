//
//  QuizModel.swift
//  QuizApp
//
//  Created by Leah Pope on 4/27/20.
//  Copyright © 2020 lsp. All rights reserved.
//

import Foundation

protocol QuizProtocol {
    func questionsRetrieved(_ questions:[Question])
}

class QuizModel {
    
    var delegate:QuizProtocol?
    
    func getQuestions() {
        getRemoteJsonFile()
    }
    
    func getLocalJsonFile() {
        // get bundle
        let path = Bundle.main.path(forResource: "QuestionData", ofType: ".json")
        
        // double check path is not nil
        guard path != nil else {
            print("Coud not find the json data file.")
            return
        }
        // get the URL using the path to the json file
        let url = URL(fileURLWithPath: path!)
        
        // get the data from the URL and do error handling
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // try to create structs from the JSON
            let array = try decoder.decode([Question].self, from: data)
            // notify delegate that we have the question data
            delegate?.questionsRetrieved(array)
        }
        catch {
            print("Cannot read data at URL")
        }
    }
    
    func getRemoteJsonFile() {
        // get a URL object
        let urlString = "https://codewithchris.com/code/QuestionData.json"
        let url = URL(string: urlString)
        
        guard url != nil else {
            print("Could not create URL object!")
            return
        }
        
        // get a URL session object
        let session = URLSession.shared
      
        // get a data task object (uses a closure) - this happens on a background thread
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            // check that there wasn't an error
            if error == nil && data != nil {
                do {
                    // create the JSON decoder object
                    let decoder = JSONDecoder()
                    
                    // parse the JSON
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // use the main thread to update UI
                    DispatchQueue.main.async {
                        // notify the View Controller/ the delegate
                        self.delegate?.questionsRetrieved(array)
                    }
                }
                catch {
                    print("There was an error with the JSON parsing!")
                }
            }
        }
        
        // call resume on the data task
        dataTask.resume()
    }
    
}
