//
//  ViewController.swift
//  Fashion CNN
//
//  Created by Rodolphe DUPUY on 05/10/2020.
//  Copyright © 2018 Rodolphe DUPUY. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultatLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageNomString = String(indexPath.item)
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? ImageCollectionViewCell {
            cell.imageVue.image = UIImage(named: imageNomString)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = UIImage(named: String(indexPath.item)), let ci = CIImage(image: image) else { return }
        //Appel CoreML
        do {
            let modele = try VNCoreMLModel(for: modele_fashion().model)
            let requete = VNCoreMLRequest(model: modele, completionHandler: reponse)
            let handler = VNImageRequestHandler(ciImage: ci, options: [:])
            try handler.perform([requete])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reponse(_ requete: VNRequest, _ error: Error?) {
        guard let resultats = requete.results, let premierResultat = resultats[0] as? VNCoreMLFeatureValueObservation, let multiArray = premierResultat.featureValue.multiArrayValue else { return }
        var meilleurResultat = 0
        var pourcentage = 0.0
        for x in (0...multiArray.count) {
            let percent = Double(multiArray[x].floatValue) * 100
            if percent > pourcentage {
                pourcentage = percent
                meilleurResultat = x
            }
        }
        let pourcentString = String(pourcentage) + "%"
        let resultat = "Cest est :" + obtenirHabit(int: meilleurResultat) + "\nIndex: \(meilleurResultat) avec un pourcentage de " + pourcentString
        self.resultatLabel.text = resultat
    }
    
    func obtenirHabit(int: Int) -> String {
        switch int {
        case 0: return "un Tee shirt"
        case 1: return "un pantalon"
        case 2: return "un pull over"
        case 3: return "une robe"
        case 4: return "une veste ou un manteau"
        case 5: return "des sandales"
        case 6: return "un pull"
        case 7: return "des baskets"
        case 8: return "un sac"
        case 9: return "des bottes"
        default: return ""
        }
    }
    
}
