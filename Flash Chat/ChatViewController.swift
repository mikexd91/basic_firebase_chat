//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target:
            self, action:#selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
//        let messageArray = ["First Message", "Second Message", "Third Message"]
//        cell.messageBody.text = messageArray[indexPath.row]
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named:"egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
        
    }
    
    
    //TODO: Declare tableViewTapped here:
    func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                scrollToLastRow()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
//    //TODO: Declare textFieldDidBeginEditing here:
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        scrollToLastRow()
//        UIView.animate(withDuration: 0.5, animations: {
//            self.heightConstraint.constant = 308
//            self.view.layoutIfNeeded()
//        })
//        
//    }
//    
//    
//    
//    //TODO: Declare textFieldDidEndEditing here:
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.heightConstraint.constant = 50
//            self.view.layoutIfNeeded()
//        })
//        
//    }

    func scrollToLastRow() {
        let numberOfSections = messageTableView.numberOfSections
        let numberOfRows = messageTableView.numberOfRows(inSection: numberOfSections-1)
        let indexPath = NSIndexPath(row: numberOfRows-1, section: numberOfSections-1)
        messageTableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }

    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
//        messageTextfield.endEditing(true)
        
        if let text = messageTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty
        {
            //do something if it's not empty
//            messageTextfield.isEnabled = false
            sendButton.isEnabled = false
            
            let messagesDB = Database.database().reference().child("Message")
            let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
            messagesDB.childByAutoId().setValue(messageDictionary){
                (error, ref) in
                if error != nil {
                    print(error)
                }else {
                    print("Message saved successfully")
                    self.messageTextfield.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.messageTextfield.text = ""
                }
            }
            
        }else{
            messageTextfield.text = ""
        }
        //TODO: Send the message to Firebase and save it in our database
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Message")
        messageDB.observe(.childAdded, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary<String, String> {
                let text = snapshotValue["MessageBody"]!
                let sender = snapshotValue["Sender"]!
                let message = Message()
                message.messageBody = text
                message.sender = sender
                
                self.messageArray.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
                self.scrollToLastRow()
            }
        })
       
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print ("Sign out success")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else{
                print("no view controllers to pop off")
                return
        }
    }
    


}
