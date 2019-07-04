//
//  ViewController.swift
//  loginDemo
//
//  Created by Bui Van Tuan on 7/3/19.
//  Copyright © 2019 Nguyen khac vu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import LineSDK
import GoogleSignIn

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginFacebook()
        setupGoogleDelegate()
        setupLineDelegate()
       
    }
    
    
    @IBAction func signINGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func signOutGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    @IBAction func LoginWithLine(_ sender: Any) {
        LineSDKLogin.sharedInstance().start()
    }
    
    @IBAction func logOutWithLine(_ sender: Any) {
        LineSDKAPILogoutCompletion.self
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let manager = LoginManager()
        manager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .cancelled:
                print("User cancel login process")
                break
            case .failed(let error):
                print("login failed with error = \(error.localizedDescription)")
                break
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!\(accessToken)")
                self.getUser()
            }
        }
    }
    
    @IBAction func logOutWithFacebook(_ sender: Any) {
        let manager = LoginManager()
        manager.logOut()
    }
}

// MARK : LoginFaceBook
extension LoginViewController {
    
    private func setupLoginFacebook() {
        let loginLogout = LoginButton(readPermissions: [ .publicProfile ])
        loginLogout.center = CGPoint(x: view.frame.size.width/2, y: 150)
        view.addSubview(loginLogout)
    }
    
    private func getUser(){
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, about, birthday"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: GraphAPIVersion.defaultVersion)) {
            response , result in
            switch result {
            case .success(let response):
                print("user facebook id ==\(response.dictionaryValue!["id"] ?? "")")
                print("user facebook name ==\(response.dictionaryValue!["name"] ?? "")")
                
                break
            case .failed(let error):
                print("We havw error fetching loggedin user profile ==\(error.localizedDescription)")
            }
        }
        connection.start()
    }
}

// MARK: LoginLine
extension LoginViewController: LineSDKLoginDelegate {
    private func setupLineDelegate() {
      LineSDKLogin.sharedInstance().delegate = self
    }
    
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        if error != nil {
            print("error \(error?.localizedDescription ?? "")")
        } else {
            let accessToken = credential?.accessToken?.accessToken ?? ""
            let userId = profile?.userID ?? ""
            print(userId)
            let displayName = profile?.displayName ?? ""
            print(displayName)
            let statusMessage = profile?.statusMessage ?? ""
            let pictureUrl = profile?.pictureURL ?? URL(string: "")
        }
    }
}

// MARK: LoginGoogle
extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    private func setupGoogleDelegate() {
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate   = self
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID
            print(userId)
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
        }
    }
}
