//
//  ViewController.swift
//  cellcomTest
//
//  Created by Alex Vaiman on 21/06/2021.
//

import UIKit

class LoginViewController: UIViewController, LoginResponseDelegate {
    
    internal static let savedTokenKey = "savedToken"
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var varificationLabel: UILabel!
    
    @IBOutlet weak var code: UITextField!
    
    @IBOutlet weak var didNotGetCode: UIButton!
    
    private let loginApi = LoginAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loginApi.loginResponseDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if UserDefaults.standard.string(forKey: LoginViewController.savedTokenKey) != nil {
            self.moveToMainView()
            return
        }
        
        self.setup()
    }
    
    func onVarificationResponse(token: String?, error: Error?) {
        self.code.isEnabled = true
        
        if (error != nil) {
            somthingWrong()
        } else {
            UserDefaults.standard.setValue(token, forKey: LoginViewController.savedTokenKey)
            self.moveToMainView()
        }
    }
    
    @objc func phoneTextFieldDidChange(_ textField: UITextField) {
        self.sendButton.isEnabled = (textField.text ?? "").isPhoneNumber
    }
    
    @objc func codeTextFieldDidChange(_ textField: UITextField) {
        let shouldSend = (textField.text ?? "").isValidCode
        if shouldSend {
            self.code.isEnabled = false
            self.sendCodeToServer()
        }
    }

    
    private func setup() {
        self.setupHideKeyboardOnTap()
        self.sendButton.isEnabled = false
        phoneNumber.addTarget(self, action: #selector(LoginViewController.phoneTextFieldDidChange(_:)), for: .editingChanged)
        code.addTarget(self, action: #selector(LoginViewController.codeTextFieldDidChange(_:)), for: .editingChanged)
        self.code.isEnabled = false
        self.varificationLabel.alpha = 0.3
        self.didNotGetCode.isEnabled = false
        
    }

    @IBAction func sendNumber(_ sender: Any) {
        self.varificationLabel.alpha = 1
        self.didNotGetCode.isEnabled = true
        self.code.isEnabled = true
        self.sendPhoneToServer()
    }
    
    private func sendPhoneToServer() {
        loginApi.sendPhoneToServer(phoneNumber: self.phoneNumber.text ?? "")
    }
    
    private func sendCodeToServer() {
        loginApi.sendCodeToServer(phoneNumber: self.phoneNumber.text ?? "", code: self.code.text ?? "")
    }
    
    private func somthingWrong() {
        print("somthing wrong try again")
        self.code.shake()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.code.text = ""
        })
    }
    
    private func moveToMainView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! MainViewController
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
}
