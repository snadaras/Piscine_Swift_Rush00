//
//  createTopicController.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/14/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

class createTopicController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        titreLbl.text = ""
        contentLbl.text = ""
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var token : String = ""
    @IBOutlet weak var titreLbl: UITextField!
    @IBOutlet weak var contentLbl: UITextView!
    var userid : Int = 0
    
    func createTopic(title: String, content: String, vc: TableViewController)
    {

        let url = NSURL(string: "https://api.intra.42.fr/v2/topics")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let param :[String: Any] =
        [
        "topic" :
            [ "kind" : "normal",
            "language_id" : "1",
            "name" : title,
            "tag_ids" : ["578"],
            "cursus_ids" : ["1"],
            "messages_attributes" :
                [
                    [
                        "author_id" : userid,
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
                print(error!)
            }
            DispatchQueue.main.async
            {
                vc.getTopics()
                vc.tableView.reloadData()
            }

            print("end create topic")

        }
        task.resume()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "backToTopic"
        {
            if let vc = segue.destination as? TableViewController
            {
                if (titreLbl.text != "" && contentLbl.text != "")
                {
                    createTopic(title: titreLbl.text!, content: contentLbl.text, vc: vc)
                }
            }
            //debugPrint("42")
        }
    }

    @IBAction func backTopic(_ sender: Any)
    {
         performSegue(withIdentifier: "backToTopic", sender: "test")
    }
    
}
