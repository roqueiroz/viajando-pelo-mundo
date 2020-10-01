//
//  PlacesTableViewController.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 21/09/20.
//

import UIKit

class PlacesTableViewController: UITableViewController {
    
    var places: [Place] = []
    var userDefault = UserDefaults.standard
    
    var lblNothing: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNothing = UILabel()
        lblNothing.text = "Nenhum local cadastrado."
        lblNothing.textAlignment = .center
        lblNothing.numberOfLines = 0
        
        self.loadPlaces()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "mapSegue" {
            let viewCtrl = segue.destination as! PlaceFinderViewController
            viewCtrl.delegate = self
        } else {
            
            let viewCtrl = segue.destination as! MapViewController
            
            switch sender {
            
                case let place as Place:
                    viewCtrl.places = [place]
                    
                default:
                    viewCtrl.places = places
            }
            
        }
        
    }
    
    //MARK: Methods
    func loadPlaces() {
        
        if let data = userDefault.data(forKey: "places") {
            
            do {
                
                places = try JSONDecoder().decode([Place].self, from: data)
                tableView.reloadData()
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func savePlaces() {
        
        let json = try? JSONEncoder().encode(places)
        
        userDefault.set(json, forKey: "places")
        
    }
    
    @objc func showAll() {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if places.count > 0 {
            
            let btnShowAll = UIBarButtonItem(title: "Mostrar todos", style: .plain, target: self, action: #selector(showAll))
            
            navigationItem.leftBarButtonItem = btnShowAll
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lblNothing
            tableView.separatorStyle = .none
        }
        
       
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let place = places[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = place.name
        
        return cell 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = places[indexPath.row]
        
        performSegue(withIdentifier: "mapSegue", sender: place)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
        
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
            
        }
    }
    
}

extension PlacesTableViewController: PlaceFinderDelegate {
    
    func addPlace(_ place: Place) {
        
        if !places.contains(place) {
            
            places.append(place)
            savePlaces()
            tableView.reloadData()
        }
        
    }
    
    
    
    
}
