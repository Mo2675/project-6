//
//  AttachViewController.swift
//  BeRealClone
//
//  Created by mohamad amroush.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class AttachViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var caption: UITextField!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    private var location: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapPhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        // Present the picker.
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            guard let image = info[.originalImage] as? UIImage else {
                print("No image found")
                return
            }
            print("image found")

            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 0

            DispatchQueue.main.async { [weak self] in
                
                // Set image on preview image view
                 self?.previewImageView.image = image

                 // Set image to use when saving post
                 self?.pickedImage = image
                    
            }
        }
        

    
    @IBAction func didTapShare(_ sender: Any) {
        view.endEditing(true)
        
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        // Create Post object
        var post = Post()

        // Set properties
        post.imageFile = imageFile
        post.caption = caption.text
        post.location = location
        // Set the user as the current user
        post.user = User.current

        // Save object in background (async)
        post.save { [weak self] result in

            // Get the current user
            if var currentUser = User.current {

                // Update the `lastPostedDate` property on the user with the current date.
                currentUser.lastPostedDate = Date()

                // Save updates to the user (async)
                currentUser.save { [weak self] result in
                    switch result {
                    case .success(let user):
                        print("✅ User Saved! \(user)")

                        // Switch to the main thread for any UI updates
                        DispatchQueue.main.async {
                            // Return to previous view controller
                            self?.navigationController?.popViewController(animated: true)
                        }

                    case .failure(let error):
                        self?.showAlert(description: error.localizedDescription)
                    }
                }
            }
        }
    }
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
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
