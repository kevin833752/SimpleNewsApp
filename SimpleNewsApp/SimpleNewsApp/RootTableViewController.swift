//
//  ViewController.swift
//  SimpleNewsApp
//
//  Created by Linus on 14-11-29.
//  Copyright (c) 2014年 Linus. All rights reserved.
//

import UIKit
import Social

var filteredNews: [XHNewsItem] = []
let limit = 10
class RootTableViewController: UITableViewController, UISearchDisplayDelegate {
    var dataSource:[XHNewsItem] = []
    var imgQueue = NSOperationQueue()
    //http://newsoflinus.sinaapp.com/api/start&limit
    let hackerNewsApiUrl = "http://newsoflinus.sinaapp.com/api/"
    var start = 0
    
    @IBOutlet var newsTableView: UITableView!
    @IBOutlet var img: UIImageView!
    
    func loadSharingImage() {
        let newsItem = dataSource[0] as XHNewsItem
        let request = NSURLRequest(URL :NSURL(string: newsItem.newsImg)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { response, data, error in
            let image = UIImage.init(data :data)
            dispatch_async(dispatch_get_main_queue(), {
                self.img.image = image
            })
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filteredNews = dataSource.filter(
            {$0.newsTitle.rangeOfString(searchString).length != 0}
        )
        return true
    }
    
//    // 刷新数据
//    func refreshData() {
//        
//        println("refreshing")
//        loadDataSource()
//        self.newsTableView.reloadData()
//        self.refreshControl!.endRefreshing()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
        newsTableView.addLegendHeaderWithRefreshingBlock { () -> Void in
            self.loadDataSource()
        }
        newsTableView.addLegendFooterWithRefreshingBlock { () -> Void in
            self.loadDataSourceMore()
        }
        
        loadDataSource()
        
//        //添加刷新
//        self.refreshControl = UIRefreshControl()
//        refreshControl!.frame.size.height = 10
//        refreshControl!.attributedTitle = NSAttributedString(string: "松手刷新新闻")
//        refreshControl!.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
//        self.newsTableView.addSubview(refreshControl!)
        
        //隐藏searchBar
//        var contentOffset = tableView.contentOffset
//        contentOffset.y += searchDisplayController!.searchBar.frame.size.height
//        tableView.contentOffset = contentOffset
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataSourceMore() {
        self.start = self.start + limit
        let a = hackerNewsApiUrl+String(start)+"&"+String(limit)
        var url = a.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var loadURL = NSURL(string: url!)
        println(url!)
        if loadURL != nil {
            println("loadURL ok")
        }else{
            println("loadURL empty")
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
                returnString = NSString(data:data,encoding:NSUTF8StringEncoding)
                
                
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as NSArray
                
                if((err?) != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                
                var currentNewsDataSource: [XHNewsItem] = []
                
                for currentNews : AnyObject in jsonResult {
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["title"] as NSString
                    newsItem.newsTime = currentNews["time"] as NSString
                    if(currentNews["img"] as NSString == " "){
                        continue
                    }else{
                        newsItem.newsImg = currentNews["img"] as NSString
                    }
                    newsItem.newsURL = currentNews["url"] as NSString
                    if(currentNews["imgArray"] as NSString == ";"){
                        continue
                    }else{
                        newsItem.newsImgArray = (currentNews["imgArray"] as String).componentsSeparatedByString(";")
                    }
                    self.dataSource.append(newsItem)
//                    currentNewsDataSource.append(newsItem)
                    dispatch_async(dispatch_get_main_queue(), {
//                        self.dataSource = currentNewsDataSource
                        self.newsTableView.reloadData()
                        self.newsTableView.footer.endRefreshing()
                    })
                }
            }
        })
    }
    
    func loadDataSource() {
        self.start = 0
        let a = hackerNewsApiUrl+String(start)+"&"+String(limit)
        var url = a.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var loadURL = NSURL(string: url!)
        println(url!)
        if loadURL != nil {
            println("loadURL ok")
        }else{
            println("loadURL empty")
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
                returnString = NSString(data:data,encoding:NSUTF8StringEncoding)
                
                
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as NSArray
                
                if((err?) != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                
                var currentNewsDataSource: [XHNewsItem] = []

                for currentNews : AnyObject in jsonResult {
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["title"] as NSString
                    newsItem.newsTime = currentNews["time"] as NSString
                    if(currentNews["img"] as NSString == " "){
                        continue
                    }else{
                        newsItem.newsImg = currentNews["img"] as NSString
                    }
                    newsItem.newsURL = currentNews["url"] as NSString
                    if(currentNews["imgArray"] as NSString == ";"){
                        continue
                    }else{
                        newsItem.newsImgArray = (currentNews["imgArray"] as String).componentsSeparatedByString(";")
                    }
                    currentNewsDataSource.append(newsItem)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dataSource = currentNewsDataSource
                        self.newsTableView.reloadData()
                        self.newsTableView.header.endRefreshing()
                    })
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchDisplayController?.searchResultsTableView {
            return filteredNews.count
        }else {
            return dataSource.count
        }
        
    }
    
//    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 80
//    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 80
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        var newsItem: XHNewsItem
        if tableView == searchDisplayController?.searchResultsTableView {
            newsItem = filteredNews[indexPath.row]
        }else {
            newsItem = dataSource[indexPath.row]
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = newsItem.newsTitle
        cell.textLabel?.sizeToFit()
        
        cell.imageView?.image = UIImage(data: NSData(contentsOfURL: NSURL(string: newsItem.newsImg)!)!)?.scaleToSize(CGSize(width: 200, height: 150))
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
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
        webview.newsImg = data.newsImg
        webview.newsTitle = data.newsTitle
        //取导航控制器,添加subView
        self.navigationController?.pushViewController(webview, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.alpha = 0
        let y = self.view.bounds.height + cell.center.y
        cell.center.y = y

        let delay:Double = Double(indexPath.row) * 0.2
        UIView.animateWithDuration(0.5, delay: delay, options: nil, animations: { () -> Void in
            cell.center.y = y - self.view.bounds.height
            cell.alpha = 1
        }, completion: nil)
        
    }
    
}

extension UIImage {
    func scaleToSize(tosize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(tosize)
        self.drawInRect(CGRectMake(0, 0, tosize.width, tosize.height))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}