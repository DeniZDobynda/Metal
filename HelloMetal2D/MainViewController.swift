//
//  MainViewController.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 17.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var rulesView: UITextView!
    @IBOutlet weak var iterationsLabel: UILabel!
    
    private var iterations = 2 {
        didSet {
            iterationsLabel.text = "\(iterations) iterations"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        iterations = Int(sender.value)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Render", let destination = segue.destination as? ViewController {
            var r = [(String, String)]()
            if let rules = rulesView.text {
                rules.enumerateLines { (line, _) in
                    let parts = line.split(separator: ":")
                    r.append((String(parts[0]), parts[1].replacingOccurrences(of: " ", with: "")))
                }
            }
            destination.tree = LTreeGenerator(with: r)
            destination.numberOfIterations = iterations
        }
    }
 

}
