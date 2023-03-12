//
//  SignUpViewController.swift
//  BeRealClone
//
//  Created by mohamad amroush.
//

import UIKit
import ParseSwift
import PhotosUI

class SignUpViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }
    
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    
    @IBAction func attachPhoto(_ sender: Any) {
        // Create a configuration object
        var config = PHPickerConfiguration()

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker
        self.present(picker, animated: true)
        // The user has granted permission
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)

        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
           // Make sure the provider can load a UIImage
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object,error  in

           // Make sure we can cast the returned object to a UIImage
           let image = object as? UIImage

  

              // UI updates (like setting image on image view) should be done on main thread
          DispatchQueue.main.async {
             // Set image to use when saving post
             self?.pickedImage = image
          }
        }
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {

        var newUser = User()
        newUser.username = username.text
        newUser.email = email.text
        newUser.password = password.text
//        guard let image = pickedImage,
//              // Create and compress image data (jpeg) from UIImage
//              let imageData = image.jpegData(compressionQuality: 0.1) else {
//            return
//        }
//        let imageFile = ParseFile(name: "profile.jpg", data: imageData)
//        newUser.image = imageFile
//
//        newUser.save { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let post):
//                    print("✅ Profile Saved! \(post)")
//
//                    // Return to previous view controller
//                    self?.navigationController?.popViewController(animated: true)
//
//                case .failure(let error):
//                    self?.showAlert(description: error.localizedDescription)
//                }
//            }
//
//        }
        newUser.signup { [weak self] result in
            
            switch result {
            case .success(let user):

                print("✅ Successfully signed up user \(user)")

                // Post a notification that the user has successfully signed up.
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                if let feedView = self?.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as? FeedViewController {
                    self?.navigationController?.pushViewController(feedView, animated: true)
                }else {
                    print("Error: unable to instantiate FeedViewController")
                }
//                performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
            case .failure(let error):
                // Failed sign up
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
