//
//  ViewController.swift
//  LEPP
//
//  Created by Garet McKinley on 10/15/15.
//  Copyright © 2015 Garet McKinley. All rights reserved.
//

import Cocoa
import Foundation

func shell(args: String...) -> String {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String

    return output
}

func nginxIsRunning() -> Bool {
    let out = shell("ps", "aux")
    if "nginx" >|< out {
        return true
    }
    return false
}

func phpIsRunning() -> Bool {
    let out = shell("ps", "aux")
    if "php-fpm" >|< out {
        return true
    }
    return false
}

func psqlIsRunning() -> Bool {
    let out = shell("ps", "aux")
    if "postgresql" >|< out {
        return true
    }
    return false
}


class ViewController: NSViewController {

    @IBOutlet weak var nginxStatus: NSLevelIndicator!
    @IBOutlet weak var phpStatus: NSLevelIndicator!
    @IBOutlet weak var psqlStatus: NSLevelIndicator!
    
    @IBOutlet weak var startNginxButton: NSButton!
    @IBOutlet weak var restartNginxButton: NSButton!
    
    @IBOutlet weak var startPHPButton: NSButton!
    @IBOutlet weak var stopPHPButton: NSButton!
    @IBOutlet weak var restartPHPButton: NSButton!
    
    @IBOutlet weak var startPsqlButton: NSButton!
    @IBOutlet weak var restartPsqlButton: NSButton!
    
    func refreshStatuses() {
        if nginxIsRunning() {
            nginxStatus.intValue = 3
            startNginxButton.title = "Stop"
            restartNginxButton.enabled = true
        } else {
            nginxStatus.intValue = 1
            startNginxButton.title = "Start"
            restartNginxButton.enabled = false
        }
        if phpIsRunning() {
            phpStatus.intValue = 3
            startPHPButton.title = "Stop"
            restartPHPButton.enabled = true
        } else {
            phpStatus.intValue = 1
            startPHPButton.title = "Start"
            restartPHPButton.enabled = false
        }
        if psqlIsRunning() {
            psqlStatus.intValue = 3
            startPsqlButton.title = "Stop"
            restartPsqlButton.enabled = true
        } else {
            psqlStatus.intValue = 1
            startPsqlButton.title = "Start"
            restartPsqlButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshStatuses()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func startNginx(sender: AnyObject) {
        if startNginxButton.title == "Start" {
            NSAppleScript(source: "do shell script \"sudo /usr/local/bin/nginx\" with administrator " +
                "privileges")!.executeAndReturnError(nil)
        } else {
            NSAppleScript(source: "do shell script \"sudo /usr/local/bin/nginx -s stop\" with administrator " +
                "privileges")!.executeAndReturnError(nil)
        }
        refreshStatuses()
    }

    @IBAction func restartNginx(sender: AnyObject) {
        NSAppleScript(source: "do shell script \"sudo /usr/local/bin/nginx -s stop && sudo /usr/local/bin/nginx\" with administrator " +
            "privileges")!.executeAndReturnError(nil)
        refreshStatuses()
    }
    @IBAction func startPHP(sender: AnyObject) {
        if startPHPButton.title == "Start" {
           NSAppleScript(source: "do shell script \"launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php*.plist\"")!.executeAndReturnError(nil)
        } else {
            NSAppleScript(source: "do shell script \"launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.php*.plist\"")!.executeAndReturnError(nil)
        }
        refreshStatuses()
    }
    @IBAction func restartPHP(sender: AnyObject) {
        NSAppleScript(source: "do shell script \"launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.php*.plist && launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php*.plist\"")!.executeAndReturnError(nil)
        refreshStatuses()
    }
}

