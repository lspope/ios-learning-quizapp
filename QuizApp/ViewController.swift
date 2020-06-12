//
//  ViewController.swift
//  QuizApp
//
//  Created by Leah Pope on 4/27/20.
//  Copyright © 2020 lsp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var rootStackView: UIStackView!
    
    var model:QuizModel = QuizModel()
    var questions = [Question]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    var resultDialog:ResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init the result dialog
        resultDialog = storyboard?.instantiateViewController(identifier: "ResultVC") as? ResultViewController
        
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // programmatically setting attribute on a control here
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        model.delegate = self
        model.getQuestions()
    }
    
    func slideInQuestion() {
        // set initial state
        stackViewTrailingConstraint.constant = -1000
        stackViewLeadingConstraint.constant = 1000
        rootStackView.alpha = 0
        view.layoutIfNeeded()
        // animate to end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.stackViewTrailingConstraint.constant = 0
            self.stackViewLeadingConstraint.constant = 0
            self.rootStackView.alpha = 1
            self.view.layoutIfNeeded()

        }, completion: nil)
    }
    
    func slideOutQuestion() {
        // set initial state
        stackViewTrailingConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        rootStackView.alpha = 1
        view.layoutIfNeeded()
        // animate to end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.stackViewTrailingConstraint.constant = -1000
            self.stackViewLeadingConstraint.constant = 1000
            self.rootStackView.alpha = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func displayQuestion() {
        // check if there are questions and currentQuestionIndex is not out of bounds
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // display question text
        questionLabel.text = questions[currentQuestionIndex].question
        
        // reload the tableview
        tableView.reloadData()
        
        // slide the question in
        slideInQuestion()
    }
    
    // MARK: - QuizProtocol methods
    func questionsRetrieved(_ questions: [Question]) {
        // get a reference to the questions
        self.questions = questions
        
        // check if we should restore the state before showing question #1
        let savedQuestionIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        if savedQuestionIndex != nil && savedQuestionIndex! < self.questions.count {
            // set the current question to the saved question
            self.currentQuestionIndex = savedQuestionIndex!
            
            // set num correct to saved number
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                self.numCorrect = savedNumCorrect!
            }
        }
        
        // display the queston
        displayQuestion()
    }
    
 
    // MARK: - UITableViewDataSource and UITableViewDelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of answers for the question
        guard questions.count > 0 else {
            return 0
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        // customize it
        let label = cell.viewWithTag(1) as? UILabel
        // return the cell
        if label != nil {
            let currentQuestion = questions[currentQuestionIndex]
            // Set the answer text of the label
            if currentQuestion.answers != nil  && indexPath.row < currentQuestion.answers!.count {
                label!.text = currentQuestion.answers![indexPath.row]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // user has tapped on a row.. check if it is correct answer
        var titleText = ""
        let currentQuestion = questions[currentQuestionIndex]
        if currentQuestion.correctAnswerIndex! == indexPath.row {
            // user got it right
            titleText = "Correct!"
            numCorrect += 1
        }
        else {
            // user got it wrong
            titleText = "Incorrect."
        }
        // slide out the question
        DispatchQueue.main.async {
            self.slideOutQuestion()
        }
        
        // show the popup
        if resultDialog != nil {
            // customize the dialog text
            resultDialog?.titleText = titleText
            resultDialog?.feedbackText = currentQuestion.feedback!
            resultDialog?.buttonText = "Next"
            
            // update UI on the main thread
            DispatchQueue.main.async {
                self.present(self.resultDialog!, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - ResultViewControllerProtocol methods
    func dialogDismissed() {
        // increment current question index
        currentQuestionIndex += 1
        
        // check that there is a next question
        if currentQuestionIndex == questions.count {
            // user has just answered the last question - show summary dialog
    
            if resultDialog != nil {
               // customize the dialog text
                resultDialog?.titleText = "Summary"
                resultDialog?.feedbackText = "You got \(numCorrect) correct of out of \(questions.count) questions."
                resultDialog?.buttonText = "Restart"
                present(resultDialog!, animated: true, completion: nil)
                
                // clear state
                StateManager.clearState()
           }
        }
        else if currentQuestionIndex < questions.count {
            // display the next question and save user state
            displayQuestion()
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)
        }
        else if currentQuestionIndex > questions.count {
            // restart
            numCorrect = 0
            currentQuestionIndex = 0
            displayQuestion()
        }
    }
      
}

