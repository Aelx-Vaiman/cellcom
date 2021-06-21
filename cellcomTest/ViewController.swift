//
//  ViewController.swift
//  cellcomTest
//
//  Created by Alex Vaiman on 21/06/2021.
//

import UIKit

class LoginViewController: UIViewController, LoginResponseDelegate {
    
    private static let savedTokenKey = "savedToken"
    
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
        let token = UserDefaults.standard.string(forKey: LoginViewController.savedTokenKey)
        self.setup()
    }
    
    func onVarificationResponse(token: String?, error: Error?) {
        DispatchQueue.main.async {
            self.code.isEnabled = true
        }
        
        if (error != nil) {
            somthingWrong()
        } else {
            UserDefaults.standard.setValue(token, forKey: LoginViewController.savedTokenKey)
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
        
        //            DispatchQueue.main.async {
        //                self.code.isEnabled = true
        //            }
        //
    }
    
    private func somthingWrong() {
        print("somthing wrong try again")
        DispatchQueue.main.async {
            self.code.shake()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.code.text = ""
        })
    }
}

extension String {
    var isPhoneNumber: Bool {
        let phoneRegex = "^[0-9]{0,1}+[0-9]{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    var isValidCode: Bool {
        let codeRegex = "^[0-9]{4}$"
        let codeTest = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codeTest.evaluate(with: self)
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

public extension UIView {
    func shake(count : Float = 4,for duration : TimeInterval = 0.5,withTranslation translation : Float = 5) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
