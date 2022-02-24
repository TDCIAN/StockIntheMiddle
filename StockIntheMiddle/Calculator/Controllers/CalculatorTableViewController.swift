//
//  CalculatorTableViewController.swift
//  StockIntheMiddle
//
//  Created by JeongminKim on 2022/02/24.
//

import UIKit
import Combine
import SnapKit

class CalculatorTableViewController: UITableViewController {
    
//    @IBOutlet weak var symbolLabel: UILabel!
    private let symbolLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        return label
    }()
//    @IBOutlet weak var nameLabel: UILabel!
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let currentValueTitleLabel: UILabel = {
        let label = UILabel()
         label.textColor = .label
         label.font = .systemFont(ofSize: 16, weight: .medium)
         label.sizeToFit()
         return label
    }()
    
    private let currentValueLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
//    @IBOutlet var currencyLabels: [UILabel]!
//    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    private let investmentAmountCurrencyLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    

    
//    @IBOutlet weak var investmentAmountLabel: UILabel!
    private let investmentAmountLabel: UILabel = {
       let label = UILabel()
        return label
    }()
//    @IBOutlet weak var gainLabel: UILabel!
    private let gainLabel: UILabel = {
       let label = UILabel()
        return label
    }()
//    @IBOutlet weak var yieldLabel: UILabel!
    private let yieldLabel: UILabel = {
       let label = UILabel()
        return label
    }()
//    @IBOutlet weak var annualReturnLabel: UILabel!
    private let annualReturnLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    
//    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    private let initialInvestmentAmountTextField: UITextField = {
       let textField = UITextField()
        return textField
    }()
//    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    private let monthlyDollarCostAveragingTextField: UITextField = {
       let textField = UITextField()
        return textField
    }()
//    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    private let initialDateOfInvestmentTextField: UITextField = {
       let textField = UITextField()
        return textField
    }()

//    @IBOutlet weak var dateSlider: UISlider!
    private let dateSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    var asset: Asset?
    
    @Published private var initialDateOfInvestmentIndex: Int?
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAveragingAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    private let calculatorPresenter = CalculatorPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setLayout()
        setupTextField()
        setupDateSlider()
        observeForm()
        resetViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        initialInvestmentAmountTextField.becomeFirstResponder()
    }
    
    private func setupViews() {
        navigationItem.title = asset?.searchResult.symbol
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        currentValueTitleLabel.text = "Current Value \(asset?.searchResult.currency.addBrackets() ?? "(USD)")"
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
//        currencyLabels.forEach { label in
//            label.text = asset?.searchResult.currency.addBrackets()
//        }
    }
    
    private func setLayout() {
        self.view.addSubviews(symbolLabel, nameLabel, currentValueTitleLabel, currentValueLabel)
        
        symbolLabel.snp.makeConstraints {
            $0.top.equalTo(25)
            $0.leading.equalTo(15)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(symbolLabel)
            $0.leading.equalTo(symbolLabel.snp.trailing).offset(10)
        }
        
        currentValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(15)
            $0.leading.equalTo(15)
        }
        
        currentValueLabel.snp.makeConstraints {
            $0.top.equalTo(currentValueTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(15)
        }
    }
    
    private func setupTextField() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            let dateSliderCount = count - 1
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }
    
    private func observeForm() {
        $initialDateOfInvestmentIndex.sink { [weak self] (index) in
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
        }
        .store(in: &subscribers)
        
//        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({ ($0.object as? UITextField)?.text }).sink { (text) in
//            print("initialInvestmentAmountTextField: \(text)")
//        }.store(in: &subscribers)
        
        // 위와 같은 코드
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap { notification -> String? in
            var text: String?
            if let textField = notification.object as? UITextField {
                text = textField.text
            }
            return text
        }.sink { [weak self] (text) in
            self?.initialInvestmentAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap { notification -> String? in
            var text: String?
            if let textField = notification.object as? UITextField {
                text = textField.text
            }
            return text
        }.sink { [weak self] (text) in
            print("monthlyDollarCostAveragingTextField: \(text)")
            self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollarCostAveragingAmount, $initialDateOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex) in
            
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                  let asset = self?.asset else { return }
            
            guard let this = self else { return }
            let result = this.dcaService.calculate(
                asset: asset,
                initialInvestmentAmount: initialInvestmentAmount.doubleValue,
                monthlyDollorCostAverageAmount: monthlyDollarCostAveragingAmount.doubleValue,
                initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            let presentation = this.calculatorPresenter.getPresentation(result: result)
            
            this.currentValueLabel.backgroundColor = presentation.currentValueLabelBackgroundColor
            this.currentValueLabel.text = presentation.currentValue
            this.investmentAmountLabel.text = presentation.investmentAmount
            this.gainLabel.text = presentation.gain
            this.yieldLabel.text = presentation.yield
            this.yieldLabel.textColor = presentation.yieldLabelTextColor
            this.annualReturnLabel.text = presentation.annualReturn
            this.annualReturnLabel.textColor = presentation.annualReturnLabelTextColor
            
        }.store(in: &subscribers)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDateSelection",
           let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController,
           let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex = initialDateOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
        }
    }
    
    private func resetViews() {
        currentValueLabel.text = "0.00"
        investmentAmountLabel.text = "0.00"
        gainLabel.text = "-"
        yieldLabel.text = "-"
        annualReturnLabel.text = "-"
    }
    
    private func handleDateSelection(at index: Int) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false
        }
        return true
    }
}
