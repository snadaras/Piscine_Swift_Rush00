//
//  ViewController.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    var token : String? = nil

    override func viewDidLoad()
    {
        super.viewDidLoad()
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0

        webView.navigationDelegate = self
        webView.uiDelegate = self
        self.navigationItem.rightBarButtonItem = nil
        

        webView.load(URLRequest(url: NSURL(string: "https://api.intra.42.fr/oauth/authorize?client_id=a632854ff611ad2c098dca9bdcef5eaf0f9e07b66ef6bae288bc866c5426081d&redirect_uri=https%3A%2F%2Fintra.42.fr&response_type=code&scope=public+forum")! as URL))
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        let url = webView.url?.absoluteString
        print(url!)

        let namehost = NSURL(string: url!)?.host
        //print(namehost!)

        if (namehost == "intra.42.fr")
        {
            decisionHandler(.cancel)
            //webView.removeFromSuperview()
            let test1 = getQueryStringParameter(url: url!, param: "code")
            //print(test1!)
            if (test1 != nil)
            {
                webView.stopLoading()
                getTokenAccess(USERKEY: test1!)
                print("OK: \(test1!)")
            }
            else
            {


                webView.load(URLRequest(url: NSURL(string: "https://api.intra.42.fr/oauth/authorize?client_id=a632854ff611ad2c098dca9bdcef5eaf0f9e07b66ef6bae288bc866c5426081d&redirect_uri=https%3A%2F%2Fintra.42.fr&response_type=code&scope=public+forum")! as URL))
                print("KO")
            }
        }
        else
        {
            decisionHandler(.allow)
        }
    }
    
    func displayError(e: NSError)
    {
        let myalert = UIAlertController(title: "Error", message: NSError.description(), preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Selected")
        })
        self.present(myalert, animated: true)
    }
    
    
    func getTokenAccess(USERKEY: String)
    {

        let CUSTOMER_KEY = "a632854ff611ad2c098dca9bdcef5eaf0f9e07b66ef6bae288bc866c5426081d"
        let CUSTOMER_SECRET = "f4625239c21a7d968bf5405836061617ea736b4dc18a1c539caaf97658c07eb2"
        
        let url = NSURL(string: "https://api.intra.42.fr/oauth/token")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=authorization_code&client_id=\(CUSTOMER_KEY)&client_secret=\(CUSTOMER_SECRET)&code=\(USERKEY)&redirect_uri=https://intra.42.fr".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            (data, response, error) in
            //print(response!)
            if error != nil{
                self.displayError(e: error! as NSError)
            }
            else if let d = data {
                do {
                    if let dic : NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        //print(dic)
                        self.token = dic["access_token"] as? String
                        DispatchQueue.main.async
                        {
                            //self.webView.stopLoading()
                            self.performSegue(withIdentifier: "showTopics", sender: self)
                        }
                    }
                }
                catch (let err){
                    self.displayError(e: err as NSError)
                }
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("SEGUE")
        if segue.identifier == "showTopics" {
            if let vc = segue.destination as? TableViewController
            {
                vc.token = self.token!
            }
        }
    }
    
    @IBAction func unWindSegueHome(_ segue: UIStoryboardSegue)
    {
        print(segue.identifier!)
    }
}
