//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

protocol CurrencyPickerDataSource {
    var currentCurrencyCode: Currency.Code { get }
    var preferredCurrencyInfos: [Currency.Info] { get }
    var supportedCurrencyInfos: [Currency.Info] { get }

    init(updateTableContentsBlock: @escaping () -> Void)
}

class CurrencyPickerViewController<DataSourceType: CurrencyPickerDataSource>: OWSTableViewController2, UISearchBarDelegate {

    private let searchBar = OWSSearchBar()
    private lazy var dataSource = DataSourceType { [weak self] in self?.updateTableContents() }
    private let completion: (Currency.Code) -> Void

    fileprivate var searchText: String? {
        searchBar.text?.ows_stripped()
    }

    public required init(completion: @escaping (Currency.Code) -> Void) {
        self.completion = completion
        super.init()

        topHeader = OWSTableViewController2.buildTopHeader(forView: searchBar)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("CURRENCY_PICKER_VIEW_TITLE",
                                  comment: "Title for the 'currency picker' view in the app settings.")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))

        searchBar.placeholder = CommonStrings.searchBarPlaceholder
        searchBar.delegate = self

        updateTableContents()
    }

    public override func applyTheme() {
        super.applyTheme()

        updateTableContents()
    }

    private func updateTableContents() {
        if let searchText = searchText,
           !searchText.isEmpty {
            updateTableContentsForSearch(searchText: searchText)
        } else {
            updateTableContentsDefault()
        }
    }

    private func updateTableContentsDefault() {
        let contents = OWSTableContents()

        let currentCurrencyCode = dataSource.currentCurrencyCode
        let preferredCurrencyInfos = dataSource.preferredCurrencyInfos
        let supportedCurrencyInfos = dataSource.supportedCurrencyInfos

        let preferredSection = OWSTableSection()
        preferredSection.customHeaderHeight = 12
        preferredSection.separatorInsetLeading = NSNumber(value: Double(OWSTableViewController2.cellHInnerMargin))
        for currencyInfo in preferredCurrencyInfos {
            preferredSection.add(buildTableItem(forCurrencyInfo: currencyInfo,
                                                currentCurrencyCode: currentCurrencyCode))
        }
        contents.addSection(preferredSection)

        let supportedSection = OWSTableSection()
        supportedSection.separatorInsetLeading = NSNumber(value: Double(OWSTableViewController2.cellHInnerMargin))
        supportedSection.headerTitle = NSLocalizedString("SETTINGS_PAYMENTS_CURRENCY_VIEW_SECTION_ALL_CURRENCIES",
                                                         comment: "Label for 'all currencies' section in the payment currency settings.")
        if supportedCurrencyInfos.isEmpty {
            supportedSection.add(OWSTableItem(customCellBlock: {
                let cell = OWSTableItem.newCell()

                let activityIndicator = UIActivityIndicatorView(style: Theme.isDarkThemeEnabled
                                                                    ? .white
                                                                    : .gray)
                activityIndicator.startAnimating()

                cell.contentView.addSubview(activityIndicator)
                activityIndicator.autoHCenterInSuperview()
                activityIndicator.autoPinEdge(toSuperviewMargin: .top, withInset: 16)
                activityIndicator.autoPinEdge(toSuperviewMargin: .bottom, withInset: 16)

                return cell
            },
            actionBlock: nil))
        } else {
            for currencyInfo in supportedCurrencyInfos {
                supportedSection.add(buildTableItem(forCurrencyInfo: currencyInfo,
                                                    currentCurrencyCode: currentCurrencyCode))
            }
        }
        contents.addSection(supportedSection)

        self.contents = contents
    }

    private func updateTableContentsForSearch(searchText: String) {

        let searchText = searchText.lowercased()

        let contents = OWSTableContents()

        let currentCurrencyCode = dataSource.currentCurrencyCode
        let preferredCurrencyInfos = dataSource.preferredCurrencyInfos
        let supportedCurrencyInfos = dataSource.supportedCurrencyInfos

        let currencyInfosToSearch = supportedCurrencyInfos.isEmpty ? preferredCurrencyInfos : supportedCurrencyInfos
        let matchingCurrencyInfos = currencyInfosToSearch.filter { currencyInfo in
            // We do the simplest possible matching.
            // No terms, no sorting by match quality, etc.
            (currencyInfo.name.lowercased().contains(searchText) ||
                currencyInfo.code.lowercased().contains(searchText))
        }

        let resultsSection = OWSTableSection()
        resultsSection.customHeaderHeight = 12
        if matchingCurrencyInfos.isEmpty {
            for currencyInfo in matchingCurrencyInfos {
                resultsSection.add(buildTableItem(forCurrencyInfo: currencyInfo,
                                                  currentCurrencyCode: currentCurrencyCode))
            }
        } else {
            for currencyInfo in matchingCurrencyInfos {
                resultsSection.add(buildTableItem(forCurrencyInfo: currencyInfo,
                                                  currentCurrencyCode: currentCurrencyCode))
            }
        }
        contents.addSection(resultsSection)

        self.contents = contents
    }

    private func buildTableItem(forCurrencyInfo currencyInfo: Currency.Info,
                                currentCurrencyCode: Currency.Code) -> OWSTableItem {

        let currencyCode = currencyInfo.code

        return OWSTableItem(customCellBlock: {
            let cell = OWSTableItem.newCell()

            let nameLabel = UILabel()
            nameLabel.text = currencyInfo.name
            nameLabel.font = UIFont.ows_dynamicTypeBodyClamped
            nameLabel.textColor = Theme.primaryTextColor

            let currencyCodeLabel = UILabel()
            currencyCodeLabel.text = currencyCode.uppercased()
            currencyCodeLabel.font = UIFont.ows_dynamicTypeFootnoteClamped
            currencyCodeLabel.textColor = Theme.secondaryTextAndIconColor

            let stackView = UIStackView(arrangedSubviews: [ nameLabel, currencyCodeLabel ])
            stackView.axis = .vertical
            stackView.alignment = .fill
            cell.contentView.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewMargins()

            cell.accessibilityIdentifier = "currency.\(currencyCode)"
            cell.accessibilityLabel = currencyInfo.name
            cell.isAccessibilityElement = true

            if currencyCode == currentCurrencyCode {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        },
        actionBlock: { [weak self] in
            self?.didSelectCurrency(currencyCode)
        })
    }

    // MARK: - Events

    @objc
    func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }

    private func didSelectCurrency(_ currencyCode: String) {
        completion(currencyCode)
        navigationController?.popViewController(animated: true)
    }

    // MARK: -

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTableContents()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateTableContents()
    }
}

struct CurrencyPickerStripeDataSource: CurrencyPickerDataSource {
    let currentCurrencyCode = Stripe.defaultCurrencyCode
    let preferredCurrencyInfos = Stripe.preferredCurrencyInfos
    let supportedCurrencyInfos = Stripe.supportedCurrencyInfos

    init(updateTableContentsBlock: @escaping () -> Void) {}
}

class CurrencyPickerPaymentsDataSource: NSObject, CurrencyPickerDataSource {
    let currentCurrencyCode = paymentsCurrenciesSwift.currentCurrencyCode
    let preferredCurrencyInfos = paymentsCurrenciesSwift.preferredCurrencyInfos
    private(set) var supportedCurrencyInfos = paymentsCurrenciesSwift.supportedCurrencyInfosWithCurrencyConversions {
        didSet { updateTableContents() }
    }

    let updateTableContents: () -> Void
    required init(updateTableContentsBlock: @escaping () -> Void) {
        self.updateTableContents = updateTableContentsBlock
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(paymentConversionRatesDidChange),
            name: PaymentsCurrenciesImpl.paymentConversionRatesDidChange,
            object: nil
        )

        paymentsCurrencies.updateConversationRatesIfStale()
    }

    @objc
    func paymentConversionRatesDidChange() {
        supportedCurrencyInfos = paymentsCurrenciesSwift.supportedCurrencyInfosWithCurrencyConversions
    }
}
