//
//  DetailsViewController.swift
//  FilmLibrary
//
//  Created by Barış Genç on 15.03.2021.
//  Copyright © 2021 BG. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filmNameField: UITextField!
    @IBOutlet weak var directorNameField: UITextField!
    @IBOutlet weak var starsField: UITextField!
    @IBOutlet weak var releaseDateField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenFilmName = ""
    var chosenFilmId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        saveButton.isEnabled = false
        
        if chosenFilmName != "" {
            
            saveButton.isEnabled = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Library")
            
            let idString = chosenFilmId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "filmName") as? String {
                            filmNameField.text = name
                        }
                        if let directorName = result.value(forKey: "directorName") as? String {
                            directorNameField.text = directorName
                        }
                        if let stars = result.value(forKey: "stars") as? String {
                            starsField.text = stars
                        }
                        if let posterData = result.value(forKey: "poster") as? Data {
                            imageView.image = UIImage(data: posterData)
                        }
                        if let releaseDate = result.value(forKey: "releaseDate") as? Int {
                            releaseDateField.text = String(releaseDate)
                        }
                    }
                }
            } catch {
                print("Error")
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        if imageView.image != nil && filmNameField.text != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newFilm = NSEntityDescription.insertNewObject(forEntityName: "Library", into: context)
            newFilm.setValue(filmNameField.text, forKey: "filmName")
            newFilm.setValue(directorNameField.text, forKey: "directorName")
            newFilm.setValue(starsField.text, forKey: "stars")
            newFilm.setValue(UUID(), forKey: "id")
            
            if let releaseDate = Int(releaseDateField.text!) {
                newFilm.setValue(releaseDate, forKey: "releaseDate")
            }
            let imageData = imageView.image?.jpegData(compressionQuality: 0.3)
            newFilm.setValue(imageData, forKey: "poster")
            
            do {
                try context.save()
                print("Film saved")
            } catch {
                print("Error")
            }
            NotificationCenter.default.post(name: NSNotification.Name("new film"), object: nil)
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Film name/poster??", preferredStyle: .alert)
            let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OkAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
