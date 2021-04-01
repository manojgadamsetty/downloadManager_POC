//
//  DownloadManagerViewController.swift
//  DownloadManager_Poc
//
//  Created by Manoj Gadamsetty on 01/04/21.
//


import UIKit

let alertControllerViewTag: Int = 500

class DownloadManagerViewController: UITableViewController {
    
    var selectedIndexPath : IndexPath!
    
    lazy var downloadManager: DownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.DownloadManager.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = DownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aString: NSString = "temp" as NSString
        aString.appendingPathComponent("")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCellForIndex(_ downloadModel: DownloadModel, index: Int) {
        let indexPath = IndexPath.init(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath)
        if let cell = cell {
            let downloadCell = cell as! DownloadingCell
            downloadCell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        }
    }
}

// MARK: UITableViewDatasource Handler Extension

extension DownloadManagerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadManager.downloadingArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "DownloadingCell"
        let cell : DownloadingCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier as String, for: indexPath) as! DownloadingCell
        
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        cell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        
        return cell
        
    }
}

// MARK: UITableViewDelegate Handler Extension

extension DownloadManagerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        self.showAppropriateActionController(downloadModel.status)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: UIAlertController Handler Extension

extension DownloadManagerViewController {
    
    func showAppropriateActionController(_ requestStatus: String) {
        
        if requestStatus == TaskStatus.downloading.description() {
            self.showAlertControllerForPause()
        } else if requestStatus == TaskStatus.failed.description() {
            self.showAlertControllerForRetry()
        } else if requestStatus == TaskStatus.paused.description() {
            self.showAlertControllerForStart()
        }
    }
    
    func showAlertControllerForPause() {
        
        let pauseAction = UIAlertAction(title: "Pause", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.pauseDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(pauseAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForRetry() {
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.retryDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(retryAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForStart() {
        
        let startAction = UIAlertAction(title: "Start", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.resumeDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(startAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func safelyDismissAlertController() {
        /***** Dismiss alert controller if and only if it exists and it belongs to DownloadManager *****/
        /***** E.g App will eventually crash if download is completed and user tap remove *****/
        /***** As it was already removed from the array *****/
        if let controller = self.presentedViewController {
            guard controller is UIAlertController && controller.view.tag == alertControllerViewTag else {
                return
            }
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

extension DownloadManagerViewController: DownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: DownloadModel, index: Int) {
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [DownloadModel]) {
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: DownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidPaused(_ downloadModel: DownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidResumed(_ downloadModel: DownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestCanceled(_ downloadModel: DownloadModel, index: Int) {
        
        self.safelyDismissAlertController()
        
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
    }
    
    func downloadRequestFinished(_ downloadModel: DownloadModel, index: Int) {
        
        self.safelyDismissAlertController()
        
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        
        let docDirectoryPath : NSString = (Utility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Utility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: DownloadModel, index: Int) {
        self.safelyDismissAlertController()
        self.refreshCellForIndex(downloadModel, index: index)
        
        debugPrint("Error while downloading file: \(String(describing: downloadModel.fileName))  Error: \(String(describing: error))")
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: DownloadModel, index: Int, location: URL) {
        let myDownloadPath = Utility.baseFilePath + "/Default folder"
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = Utility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        let path =  myDownloadPath + "/" + (fileName as String)
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
}


