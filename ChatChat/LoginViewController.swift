/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInGoogleButton: GIDSignInButton!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var ref = FIRDatabaseReference()
    var globalUser = FIRUser!(nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        // ------------------
        // Sign-in with Google
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate = self;
    }
    
    // -------------------------------------------------------
    // GOOGLE SIGN-IN
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            let authencation = user.authentication
            let credential = FIRGoogleAuthProvider.credentialWithIDToken(authencation.idToken, accessToken: authencation.accessToken)
            
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                self.performSegueWithIdentifier("LoginToChat", sender: user)
                
            })
        }
    }
    // -------------------------------------------------------
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        
        FIRAuth.auth()?.signInWithEmail(usernameTextfield.text!, password: passwordTextfield.text!, completion: { [weak self] (user, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Sign in failed: ", error.localizedDescription)
            } else {
                strongSelf.performSegueWithIdentifier("LoginToChat", sender: user)
                strongSelf.globalUser = user
                FIRAuth.auth()?.currentUser
            }
        })
    }
    
    @IBAction func registerAction(sender: AnyObject) {
        FIRAuth.auth()?.createUserWithEmail(usernameTextfield.text!, password: passwordTextfield.text!, completion: { (user, error) in
            if let error = error {
                print("Registration failed: ", error.localizedDescription)
            } else {
                self.performSegueWithIdentifier("LoginToChat", sender: user)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navigationVC = segue.destinationViewController as! UINavigationController
        let chatVC = navigationVC.viewControllers.first as! ChatViewController
        chatVC.senderId = (sender as! FIRUser).uid
        chatVC.senderDisplayName = ""
    }
}

