//
//  ViewController.swift
//  SimpleNewsApp
//
//  Created by Linus on 14-11-29.
//  Copyright (c) 2014年 Linus. All rights reserved.
//

import UIKit
import Social

class RootTableViewController: UITableViewController {
    var dataSource = []
    var imgQueue = NSOperationQueue()
    let hackerNewsApiUrl = "http://newsoflinus.sinaapp.com/api"
    
    @IBOutlet var img: UIImageView!
    func loadImage() {
        let newsItem = dataSource[0] as XHNewsItem
        let request = NSURLRequest(URL :NSURL(string: newsItem.newsImg)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { response, data, error in
            let image = UIImage.init(data :data)
            dispatch_async(dispatch_get_main_queue(), {
                self.img.image = image
            })
        })
    }
    
    @IBAction func shareDidTapped(sender: AnyObject) {
        let controller: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
        controller.setInitialText("一起来看最新的军事新闻吧，就在GitHub上https://github.com/kevin833752/SimpleNewsApp")

        controller.addImage(self.img.image)
        self.presentViewController(controller, animated: true,completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadDataSource()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadDataSource() {
        var url = hackerNewsApiUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var loadURL = NSURL(string: url!)
        println(url!)
        if loadURL != nil {
            println("ok")
        }else{
            println("empty")
        }
        
        let request: NSURLRequest = NSURLRequest(URL: loadURL!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{
            (response, data, error) -> Void in
            
            if (error? != nil) {
                //Handle Error here
                println(error)
            }else{
                //Handle data in NSData type
                
                var returnString:NSString?
                returnString=NSString(data:data,encoding:NSUTF8StringEncoding)
                
                
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as NSArray
                
                if((err?) != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                

                var currentNewsDataSource = NSMutableArray()
                for currentNews : AnyObject in jsonResult {
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["title"] as NSString
                    newsItem.newsTime = currentNews["time"] as NSString
                    newsItem.newsImg = currentNews["img"] as NSString
                    newsItem.newsURL = currentNews["url"] as NSString
                    currentNewsDataSource.addObject(newsItem)
//                    println(newsItem.newsTitle)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dataSource = currentNewsDataSource
                        self.tableView.reloadData()
                    })
                }

            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let newsItem = dataSource[indexPath.row] as XHNewsItem
        cell.textLabel.text = newsItem.newsTitle
        cell.imageView.image = UIImage(named :"cell_photo")
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        let request = NSURLRequest(URL :NSURL(string: newsItem.newsImg)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: imgQueue, completionHandler: { response, data, error in
            let image = UIImage.init(data :data)
            
            dispatch_async(dispatch_get_main_queue(), {
                cell.imageView.image = image
            })
        })
        loadImage()
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row = indexPath.row as Int
        var data = self.dataSource[row] as XHNewsItem
        //入栈
        var webview = WebViewController()
        webview.newsURL = data.newsURL
        //取导航控制器,添加subView
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    
}
