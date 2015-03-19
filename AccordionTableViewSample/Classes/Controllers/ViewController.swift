//
//  ViewController.swift
//  AccordionTableViewSample
//
//  Created by suzuki_kiwamu on 2015/03/19.
//  Copyright (c) 2015年 suzuki_kiwamu. All rights reserved.
//

import UIKit


private let ParentCellIdentifier = String(ParentCell)
private let ChildCellIdentifier = String(ChildCell)

class ViewController: UIViewController {
    
    
    // MARK: Property
    @IBOutlet weak var tableView: UITableView!
    let titles = ["Parent-1", "Parent-2", "Parent-3", "Parent-4", "Parent-5", "Parent-6"]
    var topItems = [String]()
    var subItems = [[String]]()
    var currentItemsExpanded = [Int]()
    var actualPositions = [Int]()
    var total = 0
    
    
    
    // MARK: viewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: String(ParentCell), bundle: nil), forCellReuseIdentifier: ParentCellIdentifier)
        tableView.registerNib(UINib(nibName: String(ChildCell), bundle: nil), forCellReuseIdentifier: ChildCellIdentifier)
        
        for i in 0..<titles.count {
            topItems.append(titles[i])
            actualPositions.append(-1)
            var items = [String]()
            for (var j = 0; j < 2; j++) {
                items.append(String(j))
            }
            self.subItems.append(items)
        }
        total = topItems.count
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for (var i = titles.count - 1; i >= 0; i--) {
            let cellIndexPath = NSIndexPath(forRow: i, inSection: 1)
            tableView(tableView, didSelectRowAtIndexPath: cellIndexPath)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: tableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.total
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var parent = self.findParent(indexPath.row)
        var idx = find(self.currentItemsExpanded, parent)
        var isChild = idx != nil && indexPath.row != self.actualPositions[parent]

        if isChild {
            let cell: ChildCell = dequeueChildCell() as ChildCell
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        }
        else {
            let cell: ParentCell = dequeueParentCell() as ParentCell
            cell.titleLabel.text = titles[parent]
            return cell
        }
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        
        var parent = self.findParent(indexPath.row)
        var idx = find(self.currentItemsExpanded, parent)
        var isChild = idx != nil
        if indexPath.row == self.actualPositions[parent] {
            isChild = false
        }
        
        if (isChild) {
            NSLog("A child was tapped!!!");
            return;
        }
        
        self.tableView.beginUpdates()
        //子cellを閉じる時
        if (idx != nil) {
            self.collapseSubItemsAtIndex(indexPath.row, parent: parent)
            self.actualPositions[parent] = -1
            self.currentItemsExpanded.removeAtIndex(idx!)
            for (var i = parent + 1; i < self.topItems.count; i++) {
                if self.actualPositions[i] != -1 {
                    self.actualPositions[i] -= self.subItems[parent].count
                }
            }
            //子cellを広げる時
        } else {
            self.expandItemAtIndex(indexPath.row, parent: parent)
            self.actualPositions[parent] = indexPath.row
            for (var i = parent + 1; i < self.topItems.count; i++) {
                if self.actualPositions[i] != -1 {
                    self.actualPositions[i] += self.subItems[parent].count
                }
            }
            self.currentItemsExpanded.append(parent)
        }
        self.tableView.endUpdates()
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    
    
    
    
    
    
    
    // MARK: Method
    private func dequeueChildCell() -> ChildCell {
        return tableView.dequeueReusableCellWithIdentifier(ChildCellIdentifier) as ChildCell
    }
    
    
    private func dequeueParentCell() -> ParentCell {
        return tableView.dequeueReusableCellWithIdentifier(ParentCellIdentifier) as ParentCell
    }
    
    
    
    /**
    親のcellを取得します
    :param: index indexPath.row
    :returns: 親cell
    */
    private func findParent(index : Int) -> Int {
        var parent = 0
        var i = 0
        while (true) {
            if (i >= index) {
                break
            }
            if let idx = find(self.currentItemsExpanded, parent) {
                i += self.subItems[parent].count + 1
                if (i > index) {
                    break
                }
            }
            else {
                ++i
            }
            ++parent
        }
        return parent
    }
    
    
    
    /**
    子cellを挿入する
    :param: index  tapされたindexPath.row
    :param: parent tapされた親Cell
    */
    private func expandItemAtIndex(index: Int, parent: Int) {
        var indexPaths = [NSIndexPath]()
        var currentSubItems = self.subItems[parent]
        var insertPos = index + 1
        for (var i = 0; i < currentSubItems.count; i++) {
            indexPaths.append(NSIndexPath(forRow: insertPos++, inSection: 0))
        }
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.total += self.subItems[parent].count
    }
    
    
    
    
    /**
    子cellを削除する
    :param: index  tapされたindexPath.row
    :param: parent tapされた親Cell
    */
    private func collapseSubItemsAtIndex(index: Int, parent: Int) {
        var indexPaths = [NSIndexPath]()
        for (var i = index + 1; i <= index + self.subItems[parent].count; i++ ){
            indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.total  -= self.subItems[parent].count
    }
}

