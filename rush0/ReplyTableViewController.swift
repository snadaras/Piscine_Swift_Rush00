//
//  ReplyTableViewController.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

struct Reply : CustomStringConvertible
{
    var description: String
    {
        get{
            return "(\(author), \(name), \(date))"
        }
    }
    
    var author: String
    var name: String
    var date: String
    //var id: Int
}

class ReplyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var token: String = ""
    var topic_id: Int = 0
    var msg_id: Int = 0
    var lstReply : [Reply] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lstReply.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customReplyCell") as? customReplyCell
        cell?.authorLbl.text = lstReply[indexPath.row].author
        cell?.nameLbl.text = lstReply[indexPath.row].name
        cell?.dateLbl.text = lstReply[indexPath.row].date
        cell?.nameLbl.numberOfLines = 0
        
        return cell!
    }
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

        ReplyTable.delegate = self
        ReplyTable.dataSource = self
        
        ReplyTable.estimatedRowHeight = 1000
        ReplyTable.rowHeight = UITableViewAutomaticDimension
        getReply()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var ReplyTable: UITableView!
    func getReply()
    {
        let url = NSURL(string : "https://api.intra.42.fr/v2/topics/\(self.topic_id)/messages/\(self.msg_id)/messages.json?per_page=100")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            (data, response, error) in
            print(response!)
            if error != nil{
                print(error!)
            }
            else if let d = data {
                do {
                    if let dic : NSArray = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                    {
                        print(dic)
                        DispatchQueue.main.async
                            {
                                
                                for tweet in dic as! [Dictionary<String, AnyObject>]
                                {
                                    if let author = tweet["author"] as? [String: AnyObject]
                                    {
                                        if let name = tweet["content"] as? String
                                        {
                                            if let date = tweet["created_at"] as? String
                                            {
                                                let dateformat = DateFormatter()
                                                dateformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                let newdate = dateformat.date(from: date)
                                                dateformat.dateFormat = "HH:mm:ss dd/MM/yyyy"
                                                let lastdate = dateformat.string(from: newdate!)
                                                self.lstReply.append(Reply (author: author["login"] as! String, name: name, date: lastdate))
                                                print("\(author["login"] as! String) \(name) \(date)")
                                            }
                                        }
                                    }
                                }
                                self.ReplyTable.reloadData()
                        }
                    }
                }
                catch (let err){
                    print(err)
                }
            }
        }
        task.resume()
    }


}
