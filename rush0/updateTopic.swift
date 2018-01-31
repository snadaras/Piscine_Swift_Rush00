//
//  updateTopic.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/14/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

class updateTopic: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTopic.text = oldname
        contentTopic.text = oldContent
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var titleTopic: UITextField! 
    @IBOutlet weak var contentTopic: UITextView!
    var token: String = ""
    var topicId: Int = 0
    
    var oldname: String = ""

    var oldContent : String = ""
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var content: String = ""

    @IBAction func backToMsg(_ sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: "backToMsg", sender: "test")

    }
    
    func displayError(e: NSError)
    {
        let myalert = UIAlertController(title: "Error", message: NSError.description(), preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Selected")
        })
        self.present(myalert, animated: true)
    }
    
    func updateTopic(title: String, content: String, vc: MessageTableViewController)
    {
        
        let url = NSURL(string: "https://api.intra.42.fr/v2/topics/\(topicId).json")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let param :[String: Any] =
            [
                "topic" :
                    [
                      "name" : title,
                      "messages_attributes" :
                        [
                            [
                                "content" : content
                            ]
                        ]
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
            
            //print("end update topic")
            
        }
        task.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "backToMsg"
        {
            if let vc = segue.destination as? MessageTableViewController
            {
                if (titleTopic.text != "" && contentTopic.text != "")
                {
                    updateTopic(title: titleTopic.text!, content: contentTopic.text!, vc: vc)
                }
            }
            //debugPrint("42")
        }
    }

}
