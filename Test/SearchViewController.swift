//
//  ViewController.swift
//  Test
//
//  Created by mac on 13.04.2020.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

protocol SearchViewControllerProtocol: class {
    func reloadTable()
    func animationIndicator(_ flag: Bool)
}

class SearchViewController: UIViewController {
    
    private var presenter: SearchPresenter?
    
    private let titleViewController: UILabel = {
        let title = UILabel()
        title.text = "Search Image"
        title.textColor = .black
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5
        textField.textColor = .black
        textField.backgroundColor = .clear
        textField.textAlignment = .left
        textField.placeholder = "Search"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let resultTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorInset = .zero
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SearchPresenter(view: self)
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        configurateKeyboard()
        view.addSubview(titleViewController)
        setupConstraintsTitle()
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        setupConstraintsTextField()
        resultTable.delegate = self
        resultTable.dataSource = self
        resultTable.tableFooterView = UIView()
        view.addSubview(resultTable)
        setupConstraintsResultTable()
        view.addSubview(indicator)
        setupConstraintsIndicator()
    }
    
    private func setupConstraintsTextField() {
        NSLayoutConstraint.activate([searchTextField.topAnchor.constraint(equalTo: titleViewController.bottomAnchor, constant: 30),
                                     searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                                     searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                     searchTextField.heightAnchor.constraint(equalToConstant: 40)])
    }
    
    private func setupConstraintsTitle() {
        NSLayoutConstraint.activate([titleViewController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),     titleViewController.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)])
    }
    
    private func setupConstraintsResultTable() {
        NSLayoutConstraint.activate([resultTable.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
                                     resultTable.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
                                     resultTable.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
                                     resultTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)])
    }
    
    private func setupConstraintsIndicator() {
        NSLayoutConstraint.activate([indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    private func configurateKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func hideKeyboard(notification: Notification) {
        
        let userInfo = notification.userInfo!
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func showKeyboard(notification: Notification) {
        
        let userInfo = notification.userInfo!
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.countItems() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        presenter?.configurateCell(cell, index: indexPath)
        return cell
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            presenter?.serchImage(name: text)
        }
        view.endEditing(true)
        return true
    }
    
}

extension SearchViewController: SearchViewControllerProtocol {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.resultTable.reloadData()
        }
    }
    
    func animationIndicator(_ flag: Bool) {
        
        DispatchQueue.main.async {
            if flag {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
        }
    }
    
}
