//
//  ViewController.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var jobTitleTextField: UITextField!
    
    @IBOutlet var textView: UITextView!
    
    @IBAction func addOnPressed(_ sender: UIButton) {
        createUser()
        getSingleUser()
        
    }
    
    var userList: String?
    
    @IBAction func getAllOnPressed(_ sender: UIButton) {
        getUserList()
        
    }
    

    // URL string of RESTful server
    let urlString = "https://reqres.in/api/users"
    let rest = RestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getNonExistingUser()
    }
    
    
    func getUserList() {
        
        guard let url = URL(string: urlString) else { return }
        
      
        
        rest.urlQueryParameters.add(value: "1", forKey: "page")
    
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let data = results.data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let userData = try? decoder.decode(UserData.self, from: data) else { return }
                print(userData.description)
            
                //let users = userData.data

                for user in userData.data!  {
                    print("user: ")
                    print(user)
                    
                    DispatchQueue.main.async {
                        self.textView.text =  String(user.id!) + "\n" + user.firstName! + "\n" +  user.lastName! + "\n" +  user.avatar! //userData.description
                        
                    }
                }
                
            }
            
            
//            print("\n\nResponse HTTP Headers: \n")
//            if let response = results.response {
//                for (key, value) in response.headers.allValues() {
//                    print(key, value)
//
//                }
//            }

        }
    }
    
    
    func getNonExistingUser() {
        let newUrlString = urlString + "/100"
        guard let url = URL(string: newUrlString) else { return }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let response = results.response {
                if response.httpStatusCode != 200 {
                    print("\nRequest failed with HTTP status code", response.httpStatusCode, "\n")
                }
            }
        }
    }
    

    func createUser() {
        guard let url = URL(string: urlString) else { return }
        
        guard let newUserFirstName = firstNameTextField.text else { return }
        //guard let newUserLastName = lastNameTextField.text else { return }
        guard let newUserJobTitle = jobTitleTextField.text else { return }
        
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: newUserFirstName, forKey: "name")
        //rest.httpBodyParameters.add(value: newUserLastName, forKey: "lastName")
        rest.httpBodyParameters.add(value: newUserJobTitle, forKey: "job")
        
        rest.makeRequest(toURL: url, withHttpMethod: .post) { (results) in
            guard let response = results.response else { return }
            if response.httpStatusCode == 201 {
                guard let data = results.data else { return }
                let decoder = JSONDecoder()
                guard let jobUser = try? decoder.decode(JobUser.self, from: data) else { return }
                print(jobUser.description)
            }
        }
    }
    
    
    func getSingleUser(){
        
        let newUrlString = urlString + "/1"
        guard let url = URL(string: newUrlString) else { return }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let data = results.data {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let singleUserData = try? decoder.decode(SingleUserData.self, from: data),
                    let user = singleUserData.data,
                    let avatar = user.avatar,
                    let url = URL(string: avatar) else { return }
                self.rest.getData(fromURL: url, completion: { (avatarData) in
                    guard let avatarData = avatarData else { return }
                    let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    let saveURL = cachesDirectory.appendingPathComponent("avatar.jpg")
                    try? avatarData.write(to: saveURL)
                    print("\nSaved Avatar URL: \n\(saveURL)\n")
                })
                
            }
        }
    }

}


