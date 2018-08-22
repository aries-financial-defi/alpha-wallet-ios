// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

protocol SetTransferTokensExpiryDateViewControllerDelegate: class {
    func didPressNext(TokenHolder: TokenHolder, linkExpiryDate: Date, in viewController: SetTransferTokensExpiryDateViewController)
    func didPressViewInfo(in viewController: SetTransferTokensExpiryDateViewController)
    func didPressViewContractWebPage(in viewController: SetTransferTokensExpiryDateViewController)
}

class SetTransferTokensExpiryDateViewController: UIViewController, TokenVerifiableStatusViewController {

    let config: Config
    var contract: String {
        return viewModel.token.contract
    }
    let roundedBackground = RoundedBackground()
    let scrollView = UIScrollView()
    let header = TokensViewControllerTitleHeader()
    let TokenView: TokenRowView & UIView
    let linkExpiryDateLabel = UILabel()
    let linkExpiryDateField = DateEntryField()
    let linkExpiryTimeLabel = UILabel()
    let linkExpiryTimeField = TimeEntryField()
    var datePicker = UIDatePicker()
    var timePicker = UIDatePicker()
    let descriptionLabel = UILabel()
    let noteTitleLabel = UILabel()
    let noteLabel = UILabel()
    let noteBorderView = UIView()
    let nextButton = UIButton(type: .system)
    var viewModel: SetTransferTokensExpiryDateViewControllerViewModel
    var TokenHolder: TokenHolder
    var paymentFlow: PaymentFlow
    weak var delegate: SetTransferTokensExpiryDateViewControllerDelegate?

    init(
            config: Config,
            TokenHolder: TokenHolder,
            paymentFlow: PaymentFlow,
            viewModel: SetTransferTokensExpiryDateViewControllerViewModel
    ) {
        self.config = config
        self.TokenHolder = TokenHolder
        self.paymentFlow = paymentFlow
        self.viewModel = viewModel

        let tokenType = CryptoKittyHandling(contract: TokenHolder.contractAddress)
        switch tokenType {
        case .cryptoKitty:
            TokenView = TokenListFormatRowView()
        case .otherNonFungibleToken:
            TokenView = TokenRowView()
        }

        super.init(nibName: nil, bundle: nil)

        updateNavigationRightBarButtons(isVerified: true)

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.addSubview(scrollView)

        linkExpiryDateLabel.translatesAutoresizingMaskIntoConstraints = false
        linkExpiryTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        nextButton.setTitle(R.string.localizable.aWalletNextButtonTitle(), for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        TokenView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(TokenView)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        noteBorderView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(noteBorderView)

        let col0 = [
            linkExpiryDateLabel,
            .spacer(height: 4),
            linkExpiryDateField,
        ].asStackView(axis: .vertical)
        col0.translatesAutoresizingMaskIntoConstraints = false

        let col1 = [
            linkExpiryTimeLabel,
            .spacer(height: 4),
            linkExpiryTimeField,
        ].asStackView(axis: .vertical)
        col1.translatesAutoresizingMaskIntoConstraints = false

        let choicesStackView = [col0, .spacerWidth(10), col1].asStackView()
        choicesStackView.translatesAutoresizingMaskIntoConstraints = false

        let noteStackView = [
            noteTitleLabel,
            .spacer(height: 4),
            noteLabel,
        ].asStackView(axis: .vertical)
        noteStackView.translatesAutoresizingMaskIntoConstraints = false
        noteBorderView.addSubview(noteStackView)

        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.isHidden = true
        if let locale = config.locale {
            datePicker.locale = Locale(identifier: locale)
        }

        timePicker.datePickerMode = .time
        timePicker.minimumDate = Date.yesterday
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        timePicker.isHidden = true
        if let locale = config.locale {
            timePicker.locale = Locale(identifier: locale)
        }

        let stackView = [
            header,
            TokenView,
            .spacer(height: 18),
            descriptionLabel,
            .spacer(height: 18),
            choicesStackView,
            datePicker,
            timePicker,
            .spacer(height: 10),
            noteBorderView,
        ].asStackView(axis: .vertical, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        linkExpiryDateField.translatesAutoresizingMaskIntoConstraints = false
        linkExpiryDateField.value = Date.tomorrow
        linkExpiryDateField.delegate = self

        linkExpiryTimeField.translatesAutoresizingMaskIntoConstraints = false
        linkExpiryTimeField.delegate = self

        let buttonsStackView = [nextButton].asStackView(distribution: .fillEqually, contentHuggingPriority: .required)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBar.backgroundColor = Colors.appHighlightGreen
        roundedBackground.addSubview(footerBar)

        let buttonsHeight = CGFloat(60)
        footerBar.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
			header.heightAnchor.constraint(equalToConstant: 90),

            TokenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            TokenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            linkExpiryDateField.leadingAnchor.constraint(equalTo: TokenView.background.leadingAnchor),
            linkExpiryTimeField.rightAnchor.constraint(equalTo: TokenView.background.rightAnchor),
            linkExpiryDateField.heightAnchor.constraint(equalToConstant: 50),
            linkExpiryDateField.widthAnchor.constraint(equalTo: linkExpiryTimeField.widthAnchor),
            linkExpiryDateField.heightAnchor.constraint(equalTo: linkExpiryTimeField.heightAnchor),

            datePicker.leadingAnchor.constraint(equalTo: TokenView.background.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: TokenView.background.trailingAnchor),

            timePicker.leadingAnchor.constraint(equalTo: TokenView.background.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: TokenView.background.trailingAnchor),

            noteBorderView.leadingAnchor.constraint(equalTo: TokenView.background.leadingAnchor),
            noteBorderView.trailingAnchor.constraint(equalTo: TokenView.background.trailingAnchor),

            noteStackView.leadingAnchor.constraint(equalTo: noteBorderView.leadingAnchor, constant: 10),
            noteStackView.trailingAnchor.constraint(equalTo: noteBorderView.trailingAnchor, constant: -10),
            noteStackView.topAnchor.constraint(equalTo: noteBorderView.topAnchor, constant: 10),
            noteStackView.bottomAnchor.constraint(equalTo: noteBorderView.bottomAnchor, constant: -10),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            buttonsStackView.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: footerBar.topAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: buttonsHeight),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.heightAnchor.constraint(equalToConstant: buttonsHeight),
            footerBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: view))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func nextButtonTapped() {
        let expiryDate = linkExpiryDate()
        guard expiryDate > Date() else {
            UIAlertController.alert(title: "",
                    message: R.string.localizable.aWalletTokenTokenTransferLinkExpiryTimeAtLeastNowTitle(),
                    alertButtonTitles: [R.string.localizable.oK()],
                    alertButtonStyles: [.cancel],
                    viewController: self,
                    completion: nil)
            return
        }

        delegate?.didPressNext(TokenHolder: TokenHolder, linkExpiryDate: expiryDate, in: self)
    }

    private func linkExpiryDate() -> Date {
        let hour = NSCalendar.current.component(.hour, from: linkExpiryTimeField.value)
        let minutes = NSCalendar.current.component(.minute, from: linkExpiryTimeField.value)
        let seconds = NSCalendar.current.component(.second, from: linkExpiryTimeField.value)
        if let date = NSCalendar.current.date(bySettingHour: hour, minute: minutes, second: seconds, of: linkExpiryDateField.value) {
            return date
        } else {
            return Date()
        }
    }

    func showInfo() {
        delegate?.didPressViewInfo(in: self)
    }

    func showContractWebPage() {
        delegate?.didPressViewContractWebPage(in: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        linkExpiryDateField.layer.cornerRadius = linkExpiryDateField.frame.size.height / 2
        linkExpiryTimeField.layer.cornerRadius = linkExpiryTimeField.frame.size.height / 2
    }

    @objc func datePickerValueChanged() {
        linkExpiryDateField.value = datePicker.date
    }

    @objc func timePickerValueChanged() {
        linkExpiryTimeField.value = timePicker.date
    }

    func configure(viewModel newViewModel: SetTransferTokensExpiryDateViewControllerViewModel? = nil) {
        if let newViewModel = newViewModel {
            viewModel = newViewModel
        }
        updateNavigationRightBarButtons(isVerified: isContractVerified)

        view.backgroundColor = viewModel.backgroundColor

        header.configure(title: viewModel.headerTitle)

        TokenView.configure(tokenHolder: TokenHolder)

        linkExpiryDateLabel.textAlignment = .center
        linkExpiryDateLabel.textColor = viewModel.choiceLabelColor
        linkExpiryDateLabel.font = viewModel.choiceLabelFont
        linkExpiryDateLabel.text = viewModel.linkExpiryDateLabelText

        linkExpiryTimeLabel.textAlignment = .center
        linkExpiryTimeLabel.textColor = viewModel.choiceLabelColor
        linkExpiryTimeLabel.font = viewModel.choiceLabelFont
        linkExpiryTimeLabel.text = viewModel.linkExpiryTimeLabelText

        TokenView.stateLabel.isHidden = true

        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = viewModel.descriptionLabelColor
        descriptionLabel.font = viewModel.descriptionLabelFont
        descriptionLabel.text = viewModel.descriptionLabelText

        noteTitleLabel.textAlignment = .center
        noteTitleLabel.textColor = viewModel.noteTitleLabelColor
        noteTitleLabel.font = viewModel.noteTitleLabelFont
        noteTitleLabel.text = viewModel.noteTitleLabelText

        noteLabel.textAlignment = .center
        noteLabel.numberOfLines = 0
        noteLabel.textColor = viewModel.noteLabelColor
        noteLabel.font = viewModel.noteLabelFont
        noteLabel.text = viewModel.noteLabelText

        noteBorderView.layer.cornerRadius = 20
        noteBorderView.layer.borderColor = viewModel.noteBorderColor.cgColor
        noteBorderView.layer.borderWidth = 1

        nextButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
		nextButton.backgroundColor = viewModel.buttonBackgroundColor
        nextButton.titleLabel?.font = viewModel.buttonFont
    }
}

extension SetTransferTokensExpiryDateViewController: DateEntryFieldDelegate {
    func didTap(in dateEntryField: DateEntryField) {
        datePicker.isHidden = !datePicker.isHidden
        if !datePicker.isHidden {
            datePicker.date = linkExpiryDateField.value
            timePicker.isHidden = true
        }
    }
}

extension SetTransferTokensExpiryDateViewController: TimeEntryFieldDelegate {
    func didTap(in timeEntryField: TimeEntryField) {
        timePicker.isHidden = !timePicker.isHidden
        if !timePicker.isHidden {
            timePicker.date = linkExpiryTimeField.value
            datePicker.isHidden = true
        }
    }
}
