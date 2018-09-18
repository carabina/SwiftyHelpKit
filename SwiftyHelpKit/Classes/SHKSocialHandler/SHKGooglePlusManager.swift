//
//  GoogleManager.swift
//  SwiftHelper
//
//  Created by SwiftHelper on 8/28/18.
//  Copyright © 2018 SwiftHelper. All rights reserved.
//


import Foundation
import UIKit
import GoogleSignIn
import ObjectMapper

typealias  socialuserDetailComletion = (_ userDetail:SocialUser?,_ err:Error?)->Void

class SHKGooglePlusManager: NSObject,GIDSignInDelegate,GIDSignInUIDelegate {
    //MARK:- varible Declaration
    var googleUserCompletionhandler:socialuserDetailComletion? = nil
    //    var googleLoggedUserObserver  = Observable.create(λ)
    private var onViewController:UIViewController?
    
    //MARK:- Shared instance created
    static var sharedGoogleClient: SHKGooglePlusManager = {
        let sharedGoogleObject = SHKGooglePlusManager()
        GIDSignIn.sharedInstance().delegate = sharedGoogleObject
        GIDSignIn.sharedInstance().uiDelegate = sharedGoogleObject
        return sharedGoogleObject
    }()
    
    //MARK:- Googlemanager startup method
    func setupGoogleLogin(_ viewController:UIViewController,completion:@escaping socialuserDetailComletion) {
        onViewController = viewController
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().signIn()
        googleUserCompletionhandler  = completion
    }
    
    //MARK:Google signIn delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        createGoogleUserDict(user:  user,error: error)
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        onViewController?.present(viewController, animated: true,completion: nil)
    }
    // Dismiss the "Sign in with Google"
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        onViewController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Other methods
    
    ///Create user dictionary to post on server
    ///
    /// - Parameters:
    ///   - user: user Object i.e GIDGoogleUser
    ///   - error: Error
    func createGoogleUserDict(user:GIDGoogleUser?,error:Error?) {
        if error == nil {
            let googleLoginParam = ["email":(user?.profile.email)!,"first_name":(user?.profile.givenName)!,"last_name":(user?.profile.familyName)!,"social_id":user?.userID!] as [String:Any]
             let user : SocialUser? = Mapper<SocialUser>().map(JSON: googleLoginParam)
            googleUserCompletionhandler!(user,nil)
        } else {
            googleUserCompletionhandler!(nil,error)
        }
    }
    /// Logout user from google plus
    func logoutFromGoogle(){
        GIDSignIn.sharedInstance().signOut()
    }
    
}
