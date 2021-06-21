//
//  LoginAPI.swift
//  cellcomTest
//
//  Created by Alex Vaiman on 21/06/2021.
//

import Foundation

protocol LoginResponseDelegate: AnyObject {
    func onVarificationResponse(token: String?, error: Error?)
}


class LoginAPI {
    weak var loginResponseDelegate: LoginResponseDelegate?
    
    internal func sendPhoneToServer(phoneNumber: String) {
        let url =  String(format: "https://c36raxna13.execute-api.us-east-1.amazonaws.com/test/api/customers/otp?phone=%@",phoneNumber).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      
        var request = URLRequest(url: URL(string: url ?? "")!)
        request.httpMethod = "GET"
      
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
           
        })

        task.resume()
    }
    
    internal func sendCodeToServer(phoneNumber: String, code: String) {
        let url =  String(format: "https://c36raxna13.execute-api.us-east-1.amazonaws.com/test/api/customers/validate?phone=%@&code=%@",phoneNumber, code).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      
        var request = URLRequest(url: URL(string: url ?? "")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
          
            do {
                guard let code = response?.getStatusCode(), code == 200 else {
                    let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "failed get token"])
                    DispatchQueue.main.async {
                        self.loginResponseDelegate?.onVarificationResponse(token: nil, error: err)
                    }
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let token = json["data"]?["token"] as? String
                if let token = token {
                    DispatchQueue.main.async {
                        self.loginResponseDelegate?.onVarificationResponse(token: token, error: nil)
                    }
                } else {
                    let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "failed get token"])
                    DispatchQueue.main.async {
                        self.loginResponseDelegate?.onVarificationResponse(token: nil, error: err)
                    }
                }
            } catch {
                let err = NSError(domain: "LoginApi", code: 401, userInfo: [ NSLocalizedDescriptionKey: "failed get token"])
                DispatchQueue.main.async {
                    self.loginResponseDelegate?.onVarificationResponse(token: nil, error: err)
                }
            }
        })

        task.resume()
    }
}
