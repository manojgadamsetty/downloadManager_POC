//
//  AvailableDownloadsViewController.swift
//  DownloadManager_Poc
//
//  Created by Manoj Gadamsetty on 01/04/21.
//

import UIKit

class AvailableDownloadsViewController: UITableViewController {
    
    var objDownloadingView    : DownloadManagerViewController?
    var availableDownloadsArray: [String] = []
    
    let myDownloadPath = Utility.baseFilePath + "/My Downloads"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        debugPrint("custom download path: \(myDownloadPath)")

        availableDownloadsArray.append("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        availableDownloadsArray.append("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")
        availableDownloadsArray.append("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
        availableDownloadsArray.append("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")
        availableDownloadsArray.append("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")

        self.setUpDownloadingViewController()
    }
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpDownloadingViewController() {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers as NSArray?
        let DownloadingNav : UINavigationController = tabBarTabs?.object(at: 1) as! UINavigationController
        
        objDownloadingView = DownloadingNav.viewControllers[0] as? DownloadManagerViewController
    }
}

//MARK: UITableViewDataSource Handler Extension

extension AvailableDownloadsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDownloadsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "AvailableDownloadsCell"
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier as String, for: indexPath) as UITableViewCell
        
        let fileURL  : NSString = availableDownloadsArray[(indexPath as NSIndexPath).row] as NSString
        let fileName : NSString = fileURL.lastPathComponent as NSString
        
        cell.textLabel?.text = fileName as String
        
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension AvailableDownloadsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileURL  : NSString = availableDownloadsArray[(indexPath as NSIndexPath).row] as NSString
        var fileName : NSString = fileURL.lastPathComponent as NSString
        fileName = Utility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        
        //Use it download at default path i.e document directory
//        objDownloadingView?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String)
        
        objDownloadingView?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String, destinationPath: myDownloadPath)
        
        availableDownloadsArray.remove(at: (indexPath as NSIndexPath).row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
    }
}
