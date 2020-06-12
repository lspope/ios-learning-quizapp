//
//  ResultViewController.swift
//  QuizApp
//
//  Created by Leah Pope on 4/29/20.
//  Copyright © 2020 lsp. All rights reserved.
//

import UIKit

protocol ResultViewControllerProtocol {
     func dialogDismissed()
}

class ResultViewController: UIViewController {
    
    @IBOutlet var dimView: UIView!
    @IBOutlet var dialogView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var feedbackLabel: UILabel!
    @IBOutlet var dismissButton: UIButton!
    
    var titleText = ""
    var feedbackText = ""
    var buttonText = ""
    var delegate:ResultViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // recall..this happens only ONCE!
        // round dialog box corners using the Layer in Core Animation
        dialogView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // now that the view is about to be shown, set the text
        titleLabel.text = titleText
        feedbackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        // hide the UI elements
        dimView.alpha = 0
        titleLabel.alpha = 0
        feedbackLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // fade in the UI
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 1
            self.titleLabel.alpha = 1
            self.feedbackLabel.alpha = 1
        }, completion: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        // fade out the Dim View and dismiss the popup
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 0
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
            self.delegate?.dialogDismissed()
        }
    }
    
}
