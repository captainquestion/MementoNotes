//
//  RegisterEditVC.swift
//  MapDiary
//
//  Created by canberk yılmaz on 2023-02-27.
//

import UIKit
import CoreData
import ImageViewer_swift
import CoreLocation

import AVFoundation
import Photos


class RegisterEditVC: UIViewController, UITextViewDelegate {
    
    var imageRecordArray: [UIImage] = []
    
    let modelView = ModelView()
    

    
    private var latitudeValue = Double()
    
    private var longitudeValue = Double()
        
    var locationManager = CLLocationManager()
    

    @IBOutlet weak var locationSwitchOutlet: UISwitch!
    
    @IBOutlet weak var nameTextField: UITextField!
        
    @IBOutlet weak var descMessageText: UITextView!

    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupTextView()
        
    }
    

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray {
            textView.text = ""
            textView.textColor = UIColor.label
            }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your note here!"
            textView.textColor = UIColor.systemGray
        }
    }

    func setupTextView(){
        self.descMessageText.text = "Write your note here!"
        self.descMessageText.textColor = UIColor.systemGray
        self.descMessageText.layer.borderWidth = 1.0
        self.descMessageText.layer.borderColor = UIColor.systemGray.cgColor
        self.descMessageText.layer.cornerRadius = 5.0
        self.descMessageText.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

    }
    
    
    

    
    
    @IBAction func addImageButton(_ sender: Any) {
        pickerFunc()

        
    }
    
    @IBAction func locationSwitch(_ sender: UISwitch) {
        if sender.isOn{
            //locationManager.requestAlwaysAuthorization()
            checkLocationService()
            print("Latitude Value on On=, \(latitudeValue)")

        }else {
            locationManager.stopUpdatingLocation()
            latitudeValue = 0.0
            longitudeValue = 0.0
            print("Latitude Value on OFF=, \(latitudeValue)")
        }
        
        print("Latitude Value on OFF= 2 \(latitudeValue)")

    }
    @IBAction func saveButton(_ sender: Any) {

      insertDB()
        
        
    }
    
    func insertDB(){
        let newItem = Items(context: modelView.context)
        newItem.name = nameTextField.text
        newItem.date = Date()
        newItem.images = modelView.coreDataObjectFromImages(images: imageRecordArray)
        newItem.desc = descMessageText.text
        newItem.lat = latitudeValue
        newItem.lon = longitudeValue
        modelView.saveItems()
        navigationController?.popViewController(animated: true)
    }

    
    func pickerFunc(){
        //Setting imagePicker delegate
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {action in
            imagePicker.sourceType = .camera
            //Source type is camera
            //imagePicker.allowsEditing = true
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

            switch cameraAuthorizationStatus {
            case .restricted, .denied, .notDetermined:
                self.present(self.permissionAlert(), animated: true)
                
                
            case .authorized:
                self.present(imagePicker, animated: true,completion: nil)
                
            default:
                
                break
            }

           
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {action in imagePicker.sourceType = .photoLibrary
           //Source type is library
            
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus {
            case .restricted,.denied, .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                                (newStatus) in
                                DispatchQueue.main.async {
                                    if newStatus ==  PHAuthorizationStatus.authorized {
                                        self.present(imagePicker, animated: true, completion: nil)
                                    }else{
                                        self.present(self.permissionAlert(), animated: true, completion: nil)
                                    }
                                }})
            case .authorized, .limited:
                self.present(imagePicker, animated: true, completion: nil)
        
        
            default:
                break
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action:UIAlertAction) in
           
            
            
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view //to set the source of your alert
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
                popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
            }
        }
        

        present(actionSheet, animated: true, completion: nil)
        
    }
    
}




extension RegisterEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
       

        
        if (picker.sourceType == .camera){
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            imageRecordArray.append(uiImage)
        }else {
            
        
        
        guard let url = info[.imageURL] as? URL else { return }
                if let image = url.asSmallImage {
                    imageRecordArray.append(image)
                    

                }
        }
        collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



extension RegisterEditVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageRecordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectImageCell", for: indexPath) as! SelectedImageCell
        cell.imageInTheCell.setupImageViewer(images: imageRecordArray, initialIndex: indexPath.item)
        cell.imageInTheCell.image = imageRecordArray[indexPath.row]
//        cell.delegate = self
        
        return cell
    }
    
    
    
    }

extension RegisterEditVC: PhotoCellDelegate {
    func delete(cell: SelectedImageCell) {
        if let indexPath = collectionView.indexPath(for: cell){
            //delete the photo from datasource
            imageRecordArray.remove(at: indexPath.item)
            collectionView.reloadData()
        }
    }
}

extension RegisterEditVC: CLLocationManagerDelegate{
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled() == true{
            //Setup Location Manager
            setupLocationManager()
            checkLocationAuthorization()
         
        }
        
    }
    
    func permissionAlert() -> UIAlertController{
        let alertController = UIAlertController(title: "Need Permission", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)

           let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
               guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                   return
               }
               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
           }
           let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

           alertController.addAction(cancelAction)
           alertController.addAction(settingsAction)
        return alertController
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
            
        case .denied, .notDetermined,.restricted:
            locationSwitchOutlet.isOn = false

            self.present(permissionAlert(), animated: true)
            
            
        default:
            locationSwitchOutlet.isOn = false
            self.present(permissionAlert(), animated: true)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return}
        
        latitudeValue = location.coordinate.latitude
        longitudeValue = location.coordinate.longitude
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

