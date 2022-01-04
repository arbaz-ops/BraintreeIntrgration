//
//  ViewController.swift
//  BrainTreeIntegration
//
//  Created by Carbonic-IT on 31/12/2021.
//

import UIKit
import Alamofire
import Braintree
import BraintreeDropIn
import SwiftyJSON



class ViewController: UIViewController, BTDropInControllerDelegate {
  
    
    

    @IBOutlet weak var payButton: UIButton!
    var brainTreeClient: BTAPIClient?
    var clientToken: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        AF.request("http://localhost:3000/api/generate/token", method: .get).responseData { response in
            
            if let data = response.data
            {
                
                if let dataDictionary = JSON(data).dictionaryObject
                {
                    let request = BTPayPalCheckoutRequest(amount: "233")
                    

//                    print(dataDictionary["clientToken"] as! String)
                    self.clientToken = (dataDictionary["clientToken"] as! String)
                    
                    self.brainTreeClient = BTAPIClient(authorization: self.clientToken!)
                    let payPalDriver = BTPayPalDriver(apiClient: self.brainTreeClient!)
                    do {
                        try payPalDriver.requestOneTimePayment(request, completion: { nonce, error in
                            print(nonce)
                        })
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                if let dataArray = JSON(data).arrayObject
                {
                    print(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func payTapped(_ sender: Any) {
        let request =  BTDropInRequest()
        
        request.paypalDisabled = false
        let dropIn = BTDropInController(authorization: clientToken!,request: request) { controller, result, error in
            if (error != nil) {
                print(error?.localizedDescription)
                       print("ERROR")
            } else if (result?.isCanceled == true) {
                       print("CANCELED")
                   } else if let result = result {
                       print("Payment Type :==> \(result.paymentMethodType)")
                                   print("Payment Method :==> \(result.paymentMethod)")
                                  let pay = result.paymentMethod
                                  print("Got a nonce:==> \(String(describing: pay?.nonce))")
                                   print("Payment Icon :==> \(result.paymentIcon)")
                                   print("Payment Description :==> \(result.paymentDescription)")
                       self.postNonceToServer(nonce: String(describing:pay!.nonce))
                   }
                   controller.dismiss(animated: true, completion: nil)
        }!
              let navigationController = UINavigationController(rootViewController: dropIn)
        present(navigationController, animated: true, completion: nil)
        }
       
    func postNonceToServer(nonce: String) {
        let params: [String: Any] = [
            "payment_method_nonce": nonce,
            "amount": "200.00"
        
        ]
        AF.request("http://localhost:3000/api/process/payment", method: .post, parameters: params, encoding: JSONEncoding.default).responseData { response in
            if let data = response.data
            {
                
                if let dataDictionary = JSON(data).dictionaryObject
                {
                    print(dataDictionary)
                }
                if let dataArray = JSON(data).arrayObject
                {
                    print(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                }
            }
        }
    }

    
     
    func reloadDropInData() {
        print("asdsa")
    }
    
    func editPaymentMethods(_ sender: Any) {
        print("asdsadsa")
    }
    
    
}

