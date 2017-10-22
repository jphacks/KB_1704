//
//  CameraViewController.swift
//  CognitoYourUserPoolsSample
//
//  Created by 吉川 寛樹 on 2017/10/21.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import UIKit
import AWSS3
import AWSCognito
import Foundation

class CameraViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var parameters : String = ""
    
    @IBOutlet weak var idenbutton: UIButton!
    @IBOutlet var cameraView : UIImageView!
    @IBOutlet var label : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idenbutton.isEnabled = false
        
        label.text = "Tap the [Start] to take a picture"
    
    }
    
    // カメラの撮影開始
    @IBAction func startCamera(_ sender : AnyObject) {
    
        let sourceType:UIImagePickerControllerSourceType =
            UIImagePickerControllerSourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
    
        }
        else{
            label.text = "error"
    
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
    
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
    
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage
    
        }
    
        //閉じる処理
        imagePicker.dismiss(animated: true, completion: nil)
        label.text = "Tap the [Save] to save a picture"
    
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        label.text = "Canceled"
    }
    
    
    // 写真を保存
    @IBAction func savePicture(_ sender : AnyObject) {
        var image:UIImage! = cameraView.image
        
        print(image.size.width)
        //image = image.resize(size: CGSize(width: 2000, height: 2000))
        
        
        //print(image.size.width)
        
        if image != nil {
            //UIImageWriteToSavedPhotosAlbum(image, self, #selector(CameraViewController.image(_:didFinishSavingWithError:contextInfo:)),nil)
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(CameraViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            // Amazon Cognito 認証情報プロバイダーを初期化します
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast1,
                                                                    identityPoolId:"ap-northeast-1:a5a8d056-213a-486d-8b41-0139fc524ee4")
            
            let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let text = "Upload File."
            let fileName = "test.txt"
            let filePath = "\(docDir)/\(fileName)"
            try! text.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            let transferManager = AWSS3TransferManager.default()
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()!
            uploadRequest.bucket = "facard-photo"
            uploadRequest.key = "sample.txt"
            uploadRequest.body = NSURL(string: "file://\(filePath)") as! URL
            uploadRequest.acl = .publicRead
            uploadRequest.contentType = "text/plain"
            
            transferManager.upload(uploadRequest).continueWith { (task: AWSTask) -> AnyObject? in
                if task.error == nil /*&& task.exception == nil*/ {
                    print("success")
                } else {
                    print("fail")
                }
                return nil
            }
            
            //image transfer
            //let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            //let text = "Upload File."
            
            
            
            //let fileName = cameraView.image
            //let filePath = "\(docDir)/\(fileName)"
            //try! text.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            //let transferManager = AWSS3TransferManager.default()
            
            //let uploadRequest = AWSS3TransferManagerUploadRequest()!
            let time:Int = Int(NSDate().timeIntervalSince1970)
            let myImageName:String = String(time)
            print(myImageName)
            let imagePath = getDocumentsURL().appendingPathComponent(myImageName + ".jpg")
            
            //let path = URL(fileURLWithPath: imagePath)
            if let jpegData = UIImageJPEGRepresentation(cameraView.image!, 0.8) {
                try! jpegData.write(to: imagePath!, options: .atomic)
            }
            
            let uploadRequest2 = AWSS3TransferManagerUploadRequest()!
            uploadRequest2.bucket = "facard-photo"
            uploadRequest2.key = myImageName + ".jpg"
            uploadRequest2.body = imagePath!//NSURL(string: "file://\(filePath)") as! URL
            uploadRequest2.acl = .publicRead
            uploadRequest2.contentType = "image/jpeg"
            
            transferManager.upload(uploadRequest2).continueWith { (task: AWSTask) -> AnyObject? in
                if task.error == nil /*&& task.exception == nil*/ {
                    print("success")
                } else {
                    print("fail")
                }
                return nil
            }
            
            let request: Request = Request()
            let jsonurlstr : String = "http://13.112.30.85/personalId?srcImage="  + myImageName + ".jpg"
            
            let url: URL = Foundation.URL(string: jsonurlstr)! //URL(string : jsonurlstr)!
            
            //let body: NSMutableDictionary = NSMutableDictionary()
            //body.setValue("srcImage", forKey: myImageName + ".jpg")
            
            request.get(url: url, completionHandler: { data, response, error in
                    /*if let res = response {
                        
                        //let json = JSON(data: dataFromNetworking)
                        print(res.dictionaryWithValues(forKeys: ["HP"]))
                        print(type(of:data))
                        //let dt = data(using: .utf8)!
                        do {
                            //let json = "{\"fuga\":\"aiueo\",\"foo\":999,\"user\":{\"name\":\"tenten0213\",\"age\":30}}"
                            let personInfo = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] // json->dictionary
                            print(personInfo?["HP"])
                        } catch { }
                        
                        
                    }
                    if let dat = data {
                        //print(dat)
                    }
                    if let err = error {
                        print(err)
                    }
                 })
                 
                 }
                 else{
                 label.text = "image Failed !"
                 }*/
                
                guard let data = data else {
                    print("request failed \(error)")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: String], let result = json["result"] {
                        // Parse JSON
                    }
                } catch let parseError {
                    print("parsing error: \(parseError)")
                    let responseString = String(data: data, encoding: .utf8)
                    print("raw response: \(responseString)")
                    self.parameters = responseString!
                    self.idenbutton.isEnabled = true
                }
            
            })    // error code
            
        }
    
    }
    
    func segueToSecondViewController() {
        self.performSegue(withIdentifier: "toSecondViewController", sender: self.parameters)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondViewController" {
            let secondViewController = segue.destination as! SecondViewController
            secondViewController.parameters = self.parameters
        }
    }
    
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL as NSURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
    
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    
    }
    
    /*func saveImage (image: UIImage, path: String ) -> Bool{
        //pngで保存する場合
        let pngImageData = UIImagePNGRepresentation(image)
        // jpgで保存する場合
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let url = URL(path: String)
        let result = pngImageData!.write(url: URL(path: String), options: true)
    
        return result
    }*/
    
    // 書き込み完了結果の受け取り
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
    
        if error != nil {
            print(error.code)
            label.text = "Save Failed !"
        }
        else{
            label.text = "Save Succeeded"
        }
    }
    
    // アルバムを表示
    @IBAction func showAlbum(_ sender : AnyObject) {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
    
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
    
            label.text = "Tap the [Start] to save a picture"
        }
        else{
            label.text = "error"
    
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Amazon Cognito 認証情報プロバイダーを初期化します
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast1,
                                                            identityPoolId:"ap-northeast-1:a5a8d056-213a-486d-8b41-0139fc524ee4")
    
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return true
    }
    
}
