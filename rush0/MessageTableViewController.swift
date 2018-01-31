//
//  MessageTableViewController.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

struct Message : CustomStringConvertible
{
    var description: String
    {
        get{
            return "(\(author), \(name), \(date))"
        }
    }
    
    var author: String
    var author_id : Int
    var name: String
    var date: String
    var id: Int
}

class MessageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableMessage: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //
        tableMessage.delegate = self
        tableMessage.dataSource = self
        button.isUserInteractionEnabled = false
        button = nil
        tableMessage.estimatedRowHeight = 1000
        tableMessage.rowHeight = UITableViewAutomaticDimension
        print("\(author_id) \(user_id)")
        getMessage()
        if (author_id != user_id)
        {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    var token: String = ""
    var id: Int = 0
    var lstMsgs : [Message] = []
    var author_id = 0
    var user_id = 0
    var titleTopic : String = ""

    @IBOutlet weak var editButton: UIBarButtonItem!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lstMsgs.count
    }
    @IBAction func refresh(_ sender: Any)
    {
        getMessage()
        tableMessage.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell") as? customMessageCell
        if (indexPath.row == 0)
        {
            cell?.isUserInteractionEnabled = false
        }
        else{
            cell?.isUserInteractionEnabled = true

        }
        if (lstMsgs[indexPath.row].author_id != user_id || indexPath.row == 0)
        {
            cell?.deleteButton.isHidden = true
        }
        else
        {
            cell?.deleteButton.isHidden = false
        }
        cell?.token = token
        cell?.authorLbl.text = lstMsgs[indexPath.row].author
        cell?.nameLbl.text = lstMsgs[indexPath.row].name
        cell?.dateLbl.text = lstMsgs[indexPath.row].date
        cell?.id_msg = lstMsgs[indexPath.row].id
        cell?.nameLbl.numberOfLines = 0
        cell?.deleteButton.tag = indexPath.row

        return cell!
    }
    
    func getMessage()
    {
        lstMsgs = []
        let url = NSURL(string : "https://api.intra.42.fr/v2/topics/\(self.id)/messages.json?per_page=100")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            (data, response, error) in
            //print(response!)
            if error != nil{
                print(error!)
            }
            else if let d = data {
                do {
                    if let dic : NSArray = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                    {
                        //print(dic)
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
                                                if let id = tweet["id"] as? Int
                                                {
                                                    let dateformat = DateFormatter()
                                                    dateformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                    let newdate = dateformat.date(from: date)
                                                    dateformat.dateFormat = "HH:mm:ss dd/MM/yyyy"
                                                    let lastdate = dateformat.string(from: newdate!)
                                                    self.lstMsgs.append(Message (author: author["login"] as! String, author_id: author["id"] as! Int, name: name, date: lastdate, id: id))
                                                //print("\(author["login"] as! String) \(name) \(date)")
                                                }
                                            }
                                        }
                                    }
                                }
                                self.tableMessage.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("click")
        let cell = tableView.cellForRow(at: indexPath) as! customMessageCell
        if (cell.isUserInteractionEnabled == true)
        {
            performSegue(withIdentifier: "showReply", sender: cell.id_msg)
        }
    }
    
    @IBAction func test(_ sender: UIButton)
    {
        let buttonRow = sender.tag
        
        let refreshAlert = UIAlertController(title: "Delete Message", message: "Are you sure ?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            let url = NSURL(string: "https://api.intra.42.fr/v2/messages/\(self.lstMsgs[buttonRow].id)")
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest)
            {
                (data, response, error) in
                print(response!)
                if error != nil{
                    print(error!)
                    DispatchQueue.main.async
                        {
                            self.getMessage()
                            self.tableMessage.reloadData()
                    }
                }
            }
            task.resume()
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("showReply")
        if segue.identifier == "showReply" {
            if let vc = segue.destination as? ReplyTableViewController
            {
                print("showReply test")
                vc.token = self.token
                vc.topic_id = self.id
                vc.msg_id = sender as! Int
            }
        }
        else if segue.identifier == "updateTopic"
        {
            if let vc = segue.destination as? updateTopic
            {
                print("updateTopic test")
                vc.token = self.token
                vc.topicId = self.id
                vc.oldname = self.titleTopic
                if lstMsgs.count > 0
                {
                    vc.oldContent = lstMsgs[0].name
                }
            }
        }
        else if segue.identifier == "addMessage"
        {
            if let vc = segue.destination as? addMessage
            {
                print("updateTopic test")
                vc.token = self.token
                vc.topic_id = self.id
                vc.user_id = self.user_id
            }
        }
    }

    @IBAction func unWindSegueUpdate(_ segue: UIStoryboardSegue)
    {
        print(segue.identifier!)
    }
    
    @IBAction func unWindSegueCreateMsg(_ segue: UIStoryboardSegue)
    {
        print(segue.identifier!)
    }
}
