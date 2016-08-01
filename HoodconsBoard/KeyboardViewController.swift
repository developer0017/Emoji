//
//  KeyboardViewController.swift
//  HoodconsBoard
//
//  Created by Jeremiah McAllister on 10/30/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let buttonTitles1 = ["001", "002", "003", "004", "005", "006", "007"]
        //        let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
        let buttonTitles2 = ["008", "009", "010", "011", "012", "013", "014"]
        //        let buttonTitles3 = ["CP", "Z", "X", "C", "V", "B", "N", "M", "BP"]
        let buttonTitles3 = ["015", "016", "017", "018", "019", "020", "021"]
        let buttonTitles4 = ["CHG", "SPACE", "RETURN", "BP"]
        
        var row1 = createRowOfButtons(buttonTitles1)
        var row2 = createRowOfButtons(buttonTitles2)
        var row3 = createRowOfButtons(buttonTitles3)
        var row4 = createRowOfButtons(buttonTitles4)
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addConstraintsToInputView(self.view, rowViews: [row1, row2, row3, row4])

    }
    
    func createRowOfButtons(buttonTitles: [NSString]) -> UIView {
        
        var buttons = [UIButton]()
        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        
        for buttonTitle in buttonTitles{
            
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        
        return keyboardRowView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.redColor()
        } else {
            textColor = UIColor.greenColor()
        }
    }
    
    func copyImage(imageName: String) {
        NSLog("copyImage called with name %@", imageName)
//        UIPasteboard.generalPasteboard().string = imageName
//        setValue(imageName, forPasteboardType: "string")
        let pasteImg = UIImage(named: imageName)
        UIPasteboard.generalPasteboard().image = pasteImg
    }
    
    
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 30, 30)
        let tagInt:Int? = title.toInt()
        //        if title == "001"
        if (tagInt != nil)
        {
            let imageName = title + ".png" as String
            let btnImg = UIImage(named: imageName)
            //            button.setImage(btnImg, forState: .Normal)
            button.setBackgroundImage(btnImg, forState: .Normal)
            //            button.setTitle("", forState: .Normal)
            button.tag = tagInt!
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
            button.sizeToFit()
        } else {
            switch title {
            case "BP" :
                let btnImg = UIImage(named: "del_emoji_normal.png")
                button.setBackgroundImage(btnImg, forState: .Normal)
                button.tag = -1
                button.setTranslatesAutoresizingMaskIntoConstraints(false)
                button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            case "CHG" :
                let btnImg = UIImage(named: "board_system.png")
                button.setBackgroundImage(btnImg, forState: .Normal)
                button.tag = -10
                button.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
                button.setTranslatesAutoresizingMaskIntoConstraints(false)
                button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
//            case "RETURN" :
//                proxy.insertText("\n")
//            case "SPACE" :
//                proxy.insertText(" ")
            default :
                button.setTitle(title, forState: .Normal)
                button.titleLabel?.font = UIFont.systemFontOfSize(15)
                button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                button.setTranslatesAutoresizingMaskIntoConstraints(false)
                button.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
                button.sizeToFit()
            }
            
        }
//        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        //button.sizeToFit()
        
//        if title == "CHG" {
//            button.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
//        } else {
//            button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
//        }
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        return button
    }
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as UIButton
        var proxy = textDocumentProxy as UITextDocumentProxy
        let btnTag = button.tag
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "BP" :
                proxy.deleteBackward()
            case "RETURN" :
                proxy.insertText("\n")
            case "SPACE" :
                proxy.insertText(" ")
                //            case "CHG" :
                //                self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
            }
        } else {
            if btnTag >= 1 {
//                var imageName = ""
//                if btnTag < 100 {
//                    imageName += "0"
//                }
//                if btnTag < 10 {
//                    imageName += "0"
//                }
//                imageName += String(btnTag)
//                imageName += ".png"
//                copyImage(imageName)
                var stringToInsert = ""
                switch (btnTag)
                {
                case 1:
                    stringToInsert = "A"
                case 2:
                    stringToInsert = "B"
                case 3:
                    stringToInsert = "[Angel]"
                case 4:
                    stringToInsert = "[Gas]"
                case 5:
                    stringToInsert = "[LA]"
                case 6:
                    stringToInsert = "[FU]"
                case 7:
                    stringToInsert = "[Wing]"
                case 8:
                    stringToInsert = "[Timbs]"
                case 9:
                    stringToInsert = "[Pump]"
                case 10:
                    stringToInsert = "[Hat]"
                case 11:
                    stringToInsert = "[Rolex]"
                case 12:
                    stringToInsert = "[40]"
                case 13:
                    stringToInsert = "[Pager]"
                case 14:
                    stringToInsert = "[Blunt]"
                case 15:
                    stringToInsert = "[Porsche]"
                case 16:
                    stringToInsert = "[Subway]"
                case 17:
                    stringToInsert = "[Pass]"
                case 18:
                    stringToInsert = "[Mas]"
                case 19:
                    stringToInsert = "[Hotsauce]"
                case 20:
                    stringToInsert = "[Pizza]"
                case 21:
                    stringToInsert = "[Bed]"
                default:
                    stringToInsert = "[Error]"
                }
                var imageName = ""
                if btnTag < 100 {
                    imageName += "0"
                }
                if btnTag < 10 {
                    imageName += "0"
                }
                imageName += String(btnTag)
                imageName += ".png"
                copyImage(imageName)
                stringToInsert = imageName
                proxy.insertText(stringToInsert)
            } else if btnTag == -1 {
                proxy.deleteBackward()
            }
        }
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -1)
                
            }else{
                
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 1)
                
            }else{
                
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
                
                let firstButton = buttons[0]
                var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -1)
            
            var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 1)
            
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .Height, relatedBy: .Equal, toItem: rowView, attribute: .Height, multiplier: 1.0, constant: 0)
                
                heightConstraint.priority = 800
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }

}
