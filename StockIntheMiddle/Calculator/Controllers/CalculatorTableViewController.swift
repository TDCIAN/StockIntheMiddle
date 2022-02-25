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
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let currentValueTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        return label
    }()
    
    private let currentValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "$2000.22"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        
        return label
    }()
    
    private let investmentAmountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Investment amount : "
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        
        return label
    }()
    
    private let investmentAmountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        
        return label
    }()
    
    private let gainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gain : "
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        
        return label
    }()
    
    private let gainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "-"
        return label
    }()
    
    private let yieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "-"
        return label
    }()
    
    private let annualReturnTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Annual return : "
        label.textColor = .label
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let annualReturnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "-"
        return label
    }()
    
    private let initialInvestmentAmountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your initial investment amount"
        textField.font = .systemFont(ofSize: 15, weight: .semibold)
        textField.textColor = .systemBlue
        return textField
    }()
    
    private let initialInvestmentAmountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Initial investment amount"
        label.textColor = .label
        label.font = .systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    private let monthlyDollarCostAveragingTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Monthly dollar cost averaging amount"
        textField.font = .systemFont(ofSize: 15, weight: .semibold)
        textField.textColor = .systemBlue
        return textField
    }()
    
    private let monthlyDollarCostAveragingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monthly dollar cost averaging amount"
        label.textColor = .label
        label.font = .systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    private let initialDateOfInvestmentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter the initial date of investment"
        textField.font = .systemFont(ofSize: 15, weight: .semibold)
        textField.textColor = .systemBlue
        return textField
    }()
    
    private let initialDateOfInvestmentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "initial date of investment"
        label.textColor = .label
        label.font = .systemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    private let dateSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(dateSliderDidChange(_:)), for: .valueChanged)
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
    }
    
    private func setLayout() {
        self.view.addSubviews(
            symbolLabel, nameLabel,
            currentValueTitleLabel, currentValueLabel,
            investmentAmountTitleLabel, investmentAmountLabel,
            gainTitleLabel, yieldLabel, gainLabel,
            annualReturnTitleLabel, annualReturnLabel,
            initialInvestmentAmountTextField, initialInvestmentAmountTitleLabel,
            monthlyDollarCostAveragingTextField, monthlyDollarCostAveragingTitleLabel,
            initialDateOfInvestmentTextField, initialDateOfInvestmentTitleLabel,
            dateSlider
        )
        
        symbolLabel.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.leading.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(symbolLabel)
            $0.leading.equalTo(symbolLabel.snp.trailing).offset(10)
        }
        
        currentValueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(15)
            $0.leading.equalTo(20)
        }
        
        currentValueLabel.snp.makeConstraints {
            $0.top.equalTo(currentValueTitleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(20)
        }
        
        investmentAmountTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.top.equalTo(currentValueLabel.snp.bottom).offset(10)
        }
        
        investmentAmountLabel.snp.makeConstraints {
            $0.centerY.equalTo(investmentAmountTitleLabel.snp.centerY)
            $0.leading.equalTo(investmentAmountTitleLabel.snp.trailing)
        }
        
        gainTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.top.equalTo(investmentAmountTitleLabel.snp.bottom).offset(10)
        }
        
        gainLabel.snp.makeConstraints {
            $0.centerY.equalTo(yieldLabel.snp.centerY)
            $0.leading.equalTo(gainTitleLabel.snp.trailing)
        }
        
        yieldLabel.snp.makeConstraints {
            $0.centerY.equalTo(gainTitleLabel.snp.centerY)
            $0.leading.equalTo(gainLabel.snp.trailing).offset(5)
        }
        
        annualReturnTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.top.equalTo(gainTitleLabel.snp.bottom).offset(10)
        }
        
        annualReturnLabel.snp.makeConstraints {
            $0.centerY.equalTo(annualReturnTitleLabel.snp.centerY)
            $0.leading.equalTo(annualReturnTitleLabel.snp.trailing)
        }
        
        initialInvestmentAmountTextField.snp.makeConstraints {
            $0.top.equalTo(annualReturnTitleLabel.snp.bottom).offset(30)
            $0.leading.equalTo(20)
        }
        
        initialInvestmentAmountTitleLabel.snp.makeConstraints {
            $0.top.equalTo(initialInvestmentAmountTextField.snp.bottom).offset(5)
            $0.leading.equalTo(20)
        }
        
        monthlyDollarCostAveragingTextField.snp.makeConstraints {
            $0.top.equalTo(initialInvestmentAmountTitleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(20)
        }
        
        monthlyDollarCostAveragingTitleLabel.snp.makeConstraints {
            $0.top.equalTo(monthlyDollarCostAveragingTextField.snp.bottom).offset(5)
            $0.leading.equalTo(20)
        }
        
        initialDateOfInvestmentTextField.snp.makeConstraints {
            $0.top.equalTo(monthlyDollarCostAveragingTitleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(20)
        }
        
        initialDateOfInvestmentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(initialDateOfInvestmentTextField.snp.bottom).offset(5)
            $0.leading.equalTo(20)
        }
        
        dateSlider.snp.makeConstraints {
            $0.top.equalTo(initialDateOfInvestmentTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(20)
            $0.width.equalTo(UIScreen.main.bounds.width - 40)
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
            
            this.investmentAmountLabel.text = asset.searchResult.currency + " " + presentation.investmentAmount
            this.gainLabel.text = presentation.gain
            this.yieldLabel.text = presentation.yield
            this.yieldLabel.textColor = presentation.yieldLabelTextColor
            this.annualReturnLabel.text = presentation.annualReturn
            this.annualReturnLabel.textColor = presentation.annualReturnLabelTextColor
            
        }.store(in: &subscribers)
        
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
    
    @objc func dateSliderDidChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            let dateSelectionVC = DateSelectionTableViewController()
            dateSelectionVC.timeSeriesMonthlyAdjusted = asset?.timeSeriesMonthlyAdjusted
            dateSelectionVC.selectedIndex = initialDateOfInvestmentIndex
            dateSelectionVC.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index)
            }
            self.navigationController?.pushViewController(dateSelectionVC, animated: true)
            return false
        }
        return true
    }
}
