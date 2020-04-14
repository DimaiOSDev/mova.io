//
//  ViewControlerPresenter.swift
//  Test
//
//  Created by mac on 13.04.2020.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import RealmSwift

protocol SearchPresenterProtocol {
    init(view: SearchViewControllerProtocol)
    func serchImage(name: String)
    func countItems() -> Int
    func configurateCell(_ cell: UITableViewCell, index: IndexPath)
}

class SearchPresenter: SearchPresenterProtocol {
    
    private unowned let view: SearchViewControllerProtocol
    private let realm = try! Realm()
    lazy var responseArrey: Results<ModelRealm> = { self.realm.objects(ModelRealm.self).sorted(byKeyPath: "created", ascending: false) }()
    
    required init(view: SearchViewControllerProtocol) {
        self.view = view
    }
    
    func serchImage(name: String) {
        guard let url = URL(string: "https://api.unsplash.com/search/photos?page=0&client_id=F6eOM4yqf0ix3rVsY6Bf0sGZxE_an5LnOgjcdX7yLmM&query=\(name.replacingOccurrences(of: " ", with: "+"))") else {return}
        self.view.animationIndicator(true)
        let newModel = ModelRealm()
        newModel.searchName = name
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let response = response, let data = data else {return}
            print(response)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dic = json as? NSDictionary {
                    print(dic)
                    if let i = dic.object(forKey: "results") as? NSArray {
                        if let t = i.firstObject as? NSDictionary {
                            if let r = t.object(forKey: "urls") as? NSDictionary {
                                let url = r["small"] as! String
                                print(url)
                                guard let urlImage = URL(string: url) else {return}
                                session.dataTask(with: urlImage) { (data, response, error) in
                                    self.view.animationIndicator(false)
                                    guard let data = data else {return}
                                    newModel.image = data
                                    self.addToRealm(model: newModel)
                                }.resume()
                            }
                        } else {
                            print("Not Found")
                            self.view.animationIndicator(false)
                            self.addToRealm(model: newModel)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    private func addToRealm(model: ModelRealm) {
        DispatchQueue.main.async {
            try! self.realm.write() {
                self.realm.add(model)
                self.view.reloadTable()
            }
        }
    }
    
    func countItems() -> Int {
        return responseArrey.count
    }
    
    func configurateCell(_ cell: UITableViewCell, index: IndexPath) {
        cell.selectionStyle = .none
        
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel?.leftAnchor.constraint(equalTo: cell.imageView!.rightAnchor, constant: 10).isActive = true
        cell.textLabel?.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.textLabel?.rightAnchor.constraint(lessThanOrEqualTo: cell.rightAnchor, constant: 0).isActive = true
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = responseArrey[index.row].searchName
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        cell.imageView?.heightAnchor.constraint(equalToConstant: 100).isActive = true
        cell.imageView?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cell.imageView?.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.imageView?.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 0).isActive = true
        cell.imageView?.image = UIImage(data: responseArrey[index.row].image) ?? UIImage(imageLiteralResourceName: "baseline_broken_image")
    }
    
}
