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
import ZaloSDK

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginFacebook()
        setupGoogleDelegate()
        setupLineDelegate()
       
       
    }
    
    @IBAction func loginWithZalo(_ sender: Any) {
        login()
    }
    
    @IBAction func logOutWithZalo(_ sender: Any) {
        logout()
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

//MARK : loginzalo
extension LoginViewController {
    func login() {
        ZaloSDK.sharedInstance().authenticateZalo(with: ZAZAloSDKAuthenTypeViaZaloAppAndWebView, parentController: self) { (response) in
            if response?.isSucess == true {
                self.showProfile()
            }
        }
    }
        func logout() {
            ZaloSDK.sharedInstance().unauthenticate()
        }
        
        func showProfile() {
            ZaloSDK.sharedInstance().getZaloUserProfile { (response) in
                self.onLoad(profile: response)
            }
        }
        
        func onLoad(profile: ZOGraphResponseObject?) {
            guard let profile = profile,
                profile.isSucess,
                let name = profile.data["name"] as? String,
                let id = profile.data["id"] as? String,
                let gender = profile.data["gender"] as? String,
                let picture = profile.data["picture"] as? [String: Any?],
                let pictureData = picture["data"] as? [String: Any?],
                let sUrl = pictureData["url"] as? String,
                let url = URL(string: sUrl)
                else {
                    return
            }
            print(id)
        }
    }

