//
//  addMessage.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/14/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

class addMessage: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var contentMessage: UITextView!
    var token : String = ""
    var topic_id: Int = 0
    var user_id : Int = 0
    
    func displayError(e: NSError)
    {
        let myalert = UIAlertController(title: "Error", message: NSError.description(), preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Selected")
        })
        self.present(myalert, animated: true)
    }
   
    func createMsg(content: String, vc: MessageTableViewController)
    {
        
        let url = NSURL(string: "https://api.intra.42.fr/v2/topics/\(topic_id)/messages.json")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let param :[String: Any] =
            [
                "message" :
                [
                    "author_id" : user_id,
                    "content" : content
                ]
        ]
        
        //print(param)
        let json = try? JSONSerialization.data(withJSONObject: param)
        
        request.httpBody = json
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            (data, response, error) in
            //print(response!)
            if error != nil{
                self.displayError(e: error! as NSError)
            }
            DispatchQueue.main.async
                {
                    vc.getMessage()
                    vc.tableMessage.reloadData()
                }
            //print("end create topic")
            
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "backToMsg"
        {
            if let vc = segue.destination as? MessageTableViewController
            {
                if (contentMessage.text != "")
                {
                    createMsg(content: contentMessage.text, vc: vc)
                }
            }
        }
    }
    
    @IBAction func backMsg(_ sender: Any)
    {
        performSegue(withIdentifier: "backToMsg", sender: "test")
    }
    
}
