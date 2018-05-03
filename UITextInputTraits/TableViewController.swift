//
//  ViewController.swift
//  UITextInputTraits
//
//  Created by Mark Murray on 5/1/18.
//  Copyright © 2018 Mark Edward Murray. All rights reserved.
//

import UIKit

class TextfieldCell: UITableViewCell {
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 5
        textField.backgroundColor = .groupTableViewBackground
        return textField
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 40).isActive = true
        textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class TableViewController: UITableViewController {
    enum Sections: Int {
        case textInput
        case keyboardType
        case keyboardAppearance
        case returnKeyType
        
        static var count: Int { return 4 }
    }
    
    var textField: UITextField!
    
    var editingSection: Sections?
    
    var keyboardType: UIKeyboardType {
        set {
            textField.keyboardType = newValue
            reload(section: .keyboardType)
        }
        get {
            return textField.keyboardType
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        set {
            textField.keyboardAppearance = newValue
            reload(section: .keyboardAppearance)
        }
        get {
            return textField.keyboardAppearance
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        set {
            textField.returnKeyType = newValue
            reload(section: .returnKeyType)
        }
        get {
            return textField.returnKeyType
        }
    }
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "UITextInputTraits"
        
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame:
            CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)
        )
    }
    
    func reload(section: Sections) {
        let indexPath = IndexPath(row: 0, section: section.rawValue)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section)! {
        case .textInput:
            return "Text Input"
        case .keyboardType:
            return String(describing: UIKeyboardType.self)
        case .keyboardAppearance:
            return String(describing: UIKeyboardAppearance.self)
        case .returnKeyType:
            return String(describing: UIReturnKeyType.self)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextfieldCell()
     
        switch Sections(rawValue: indexPath.section)! {
        case .textInput:
            textField = cell.textField
            textField.delegate = self
        case .keyboardType:
            cell.textField.text = keyboardType.displayText
            cell.textField.inputView = pickerView
            cell.textField.delegate = self
            cell.textField.tag = Sections.keyboardType.rawValue
        case .keyboardAppearance:
            cell.textField.text = keyboardAppearance.displayText
            cell.textField.inputView = pickerView
            cell.textField.delegate = self
            cell.textField.tag = Sections.keyboardAppearance.rawValue
        case .returnKeyType:
            cell.textField.text = returnKeyType.displayText
            cell.textField.inputView = pickerView
            cell.textField.delegate = self
            cell.textField.tag = Sections.returnKeyType.rawValue
        }
     
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        textField.resignFirstResponder()
    }
}

extension TableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        editingSection = Sections(rawValue: textField.tag)
        
        pickerView.reloadAllComponents()
        
        let pickerViewRow: Int
        switch editingSection! {
        case .textInput:
            pickerViewRow = 0
        case .keyboardType:
            pickerViewRow = keyboardType.rawValue
        case .keyboardAppearance:
            pickerViewRow = keyboardAppearance.rawValue
        case .returnKeyType:
            pickerViewRow = returnKeyType.rawValue
        }
        pickerView.selectRow(pickerViewRow, inComponent: 0, animated: false)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

extension TableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let editingSection = editingSection else { return 0 }
        switch editingSection {
        case .textInput: return 0
        case .keyboardType:
            return UIKeyboardType.count
        case .keyboardAppearance:
            return UIKeyboardAppearance.count
        case .returnKeyType:
            return UIReturnKeyType.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let editingSection = editingSection else { return nil }
        switch editingSection {
        case .textInput: return nil
        case .keyboardType:
            return UIKeyboardType(rawValue: row)?.displayText
        case .keyboardAppearance:
            return UIKeyboardAppearance(rawValue: row)?.displayText
        case .returnKeyType:
            return UIReturnKeyType(rawValue: row)?.displayText
        }
    }
}

extension TableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let editingSection = editingSection else { return }
        switch editingSection {
        case .textInput: return
        case .keyboardType:
            guard let keyboardType = UIKeyboardType(rawValue: row) else { return }
            self.keyboardType = keyboardType
        case .keyboardAppearance:
            guard let keyboardAppearance = UIKeyboardAppearance(rawValue: row) else { return }
            self.keyboardAppearance = keyboardAppearance
        case .returnKeyType:
            guard let returnKeyType = UIReturnKeyType(rawValue: row) else { return }
            self.returnKeyType = returnKeyType
        }
    }
}

extension UIKeyboardType {
    var displayText: String {
        switch self {
        case .asciiCapable:
            return ".asciiCapable"
        case .asciiCapableNumberPad:
            return ".asciiCapableNumberPad"
        case .decimalPad:
            return ".decimalPad"
        case .default:
            return ".default"
        case .emailAddress:
            return ".emailAddress"
        case .namePhonePad:
            return ".namePhonePad"
        case .numberPad:
            return ".numberPad"
        case .numbersAndPunctuation:
            return ".numbersAndPunctuation"
        case .phonePad:
            return ".phonePad"
        case .twitter:
            return ".twitter"
        case .URL:
            return ".URL"
        case .webSearch:
            return ".websearch"
        }
    }
    
    static var count: Int { return 11 }
}

extension UIKeyboardAppearance {
    var displayText: String {
        switch self {
        case .dark:
            return ".dark"
        case .default:
            return ".default"
        case .light:
            return ".light"
        }
    }
    
    static var count: Int { return 3 }
}

extension UIReturnKeyType {
    var displayText: String {
        switch self {
        case .continue:
            return ".continue"
        case .default:
            return ".default"
        case .done:
            return ".done"
        case .emergencyCall:
            return ".emergencyCall"
        case .go:
            return ".go"
        case .google:
            return ".google"
        case .join:
            return ".join"
        case .next:
            return ".next"
        case .route:
            return ".route"
        case .search:
            return ".search"
        case .send:
            return ".send"
        case .yahoo:
            return ".yahoo"
        }
    }
    
    static var count: Int { return 12 }
}
