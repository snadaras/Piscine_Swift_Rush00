//
//  TableViewController.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

struct Topic : CustomStringConvertible
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
    var id: Int
    var author_id : Int
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var pressGesture: UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("token: \(self.token)")
        self.navigationItem.setHidesBackButton(true, animated:true);
        //self.navigationItem.rightBarButtonItem = nil
        tableView.delegate = self
        tableView.dataSource = self
        button.isUserInteractionEnabled = false
        button = nil
        getUserId()
        getTopics()
        
    }
    
    @IBAction func refreshTopics(_ sender: UIBarButtonItem)
    {
        getTopics()
    }
    

    @IBOutlet weak var button: UIButton!
    var token: String = ""
    var lstTopics : [Topic] = []
    var userId: Int = 0

    @IBOutlet weak var tableView: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lstTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as? customCellTableViewCell
        cell?.authorLbl.text = lstTopics[indexPath.row].author
        cell?.nameLbl.text = lstTopics[indexPath.row].name
        cell?.dateLbl.text = lstTopics[indexPath.row].date
        cell?.id = lstTopics[indexPath.row].id
        cell?.token = token
        cell?.author_id = lstTopics[indexPath.row].author_id
        cell?.titleTopic = lstTopics[indexPath.row].name
        cell?.deleteButton.tag = indexPath.row
        if (lstTopics[indexPath.row].author_id != userId)
        {
            cell?.deleteButton.isHidden = true
        }
        else
        {
            cell?.deleteButton.isHidden = false
        }
        return cell!
    }
    @IBAction func deleteTopics(_ sender: UIButton)
    {
        let buttonRow = sender.tag
        
        let refreshAlert = UIAlertController(title: "Delete Topic", message: "Are you sure ?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            let url = NSURL(string: "https://api.intra.42.fr/v2/topics/\(self.lstTopics[buttonRow].id).json")
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
                    }
                    DispatchQueue.main.async
                        {
                            self.getTopics()
                            self.tableView.reloadData()
                    }
                }
                task.resume()
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    func getUserId()
    {
        let url = NSURL(string : "https://api.intra.42.fr/v2/me")
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
            else if let d = data
            {
                do {
                    if let dic : NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        //print(dic)
                        self.userId = dic["id"] as! Int
                    }
                }
                catch (let err){
                    print(err)
                }
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        print(lstTopics[indexPath.row].author)
    }
    
    func getTopics()
    {
        print("get topics")

        lstTopics = []
        let url = NSURL(string : "https://api.intra.42.fr/v2/topics.json?per_page=100")
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
            else if let d = data
            {
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
                                        if let name = tweet["name"] as? String
                                        {
                                            if let date = tweet["created_at"] as? String
                                            {
                                                                        //2017-11-22T13:42:13.251Z
                                                let dateformat = DateFormatter()
                                                dateformat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                let newdate = dateformat.date(from: date)
                                                dateformat.dateFormat = "HH:mm:ss dd/MM/yyyy"
                                                let lastdate = dateformat.string(from: newdate!)
                                                self.lstTopics.append(Topic (author: author["login"] as! String, name: name, date: lastdate, id: tweet["id"] as! Int, author_id: author["id"] as! Int))
                                                //print("\("author") \(name) \(date)")
                                            }
                                        }
                                    }
                                }
                                self.tableView.reloadData()
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
    @IBAction func exit(_ sender: Any)
    {
        performSegue(withIdentifier: "backToHome", sender: "test")

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! customCellTableViewCell
        performSegue(withIdentifier: "showMessage", sender: cell)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showMessage"
        {
            if let vc = segue.destination as? MessageTableViewController
            {
                let x = sender as! customCellTableViewCell
                print("showmessage test")
                vc.token = self.token
                vc.id = x.id
                vc.user_id = self.userId
                vc.author_id = x.author_id
                vc.titleTopic = x.titleTopic
            }
        }
        else if segue.identifier == "createTopic"
        {
            if let vc = segue.destination as? createTopicController
            {
                print("createTopic test")
                vc.token = self.token
                vc.userid = self.userId
            }
        }
        else if segue.identifier == "backToHome"
        {
            if let vc = segue.destination as? ViewController
            {
                vc.token = ""
            }
            //debugPrint("42")
        }
    }

    @IBAction func unWindSegue(_ segue: UIStoryboardSegue)
    {
        print(segue.identifier!)
    }
}
