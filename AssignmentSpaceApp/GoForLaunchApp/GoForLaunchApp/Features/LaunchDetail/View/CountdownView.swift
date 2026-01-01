//
//  CountdownView.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 12.10.2025.
//

import UIKit

final class CountdownView: UIView {
    
    private let containerStack = UIStackView()
    private let countdownStack = UIStackView()
    private let statusStack = UIStackView()
    
    private let statusLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let dayValueLabel = UILabel()
    private let hourValueLabel = UILabel()
    private let minuteValueLabel = UILabel()
    
    private var targetDate: Date?
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit { timer?.invalidate() }
}

extension CountdownView: ViewBuilderProtocol {
    func configuration() {
        buildHierarchy()
        setupStyles()
        setupConstraints()
    }

    func buildHierarchy() {
        addSubview(containerStack)

        [countdownStack, statusStack].forEach(containerStack.addArrangedSubview(_:))

        countdownStack.addArrangedSubview(makeChipColumn(bindTo: dayValueLabel,   title: "Days"))
        countdownStack.addArrangedSubview(makeChipColumn(bindTo: hourValueLabel,  title: "Hours"))
        countdownStack.addArrangedSubview(makeChipColumn(bindTo: minuteValueLabel,title: "Minutes"))

        [statusLabel, dateLabel].forEach(statusStack.addArrangedSubview(_:))
    }

    func setupStyles() {
        // container
        containerStack.axis = .vertical
        containerStack.spacing = ViewMetrics.viewElementSpacing
        containerStack.alignment = .fill

        // countdown row
        countdownStack.axis = .horizontal
        countdownStack.spacing = ViewMetrics.viewElementInsideSpacing
        countdownStack.distribution = .fillEqually

        // status area
        statusStack.axis = .vertical
        statusStack.alignment = .center
        statusStack.spacing = 6

        statusLabel.text = nil
        statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusLabel.textColor = AppColors.accent

        dateLabel.text = nil
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .lightGray
        
        [dayValueLabel, hourValueLabel, minuteValueLabel].forEach {
            $0.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
            $0.textAlignment = .center
            $0.textColor = .white
            $0.text = "00"
        }
    }

    private func makeChipColumn(bindTo label: UILabel, title: String) -> UIView {
        let column = UIStackView()
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 8

        let chip = UIView()
        chip.backgroundColor = AppColors.cardBackground
        chip.layer.cornerRadius = ViewMetrics.radius

        chip.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: chip.centerYAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        column.addArrangedSubview(chip)
        column.addArrangedSubview(titleLabel)

        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.heightAnchor.constraint(equalToConstant: 64).isActive = true

        return column
    }

    func setupConstraints() {
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewMetrics.leadingConstraint),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: ViewMetrics.trailingConstraint),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ViewMetrics.bottomConstraint)
        ])
    }
}

extension CountdownView {

    @MainActor
    func startCountdown(to date: Date) {
        targetDate = date
        dateLabel.text = "Date: " + DateFormatter.defaultDateFormat.string(from: date)
        timer?.invalidate()
        
        updateCountdown()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCountdown()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    @MainActor
    func configure(with date: Date) {
        startCountdown(to: date)
    }
}

// MARK: - Internal
private extension CountdownView {
    @MainActor
    func updateCountdown() {
        guard let target = targetDate else { return }
        let now = Date()
        
        if target <= now {
            statusLabel.text = "Launched"
            dayValueLabel.text = "00"
            hourValueLabel.text = "00"
            minuteValueLabel.text = "00"
            timer?.invalidate()
            timer = nil
            return
        }
        
        let comps = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: target)
        let d = max(0, comps.day ?? 0)
        let h = max(0, comps.hour ?? 0)
        let m = max(0, comps.minute ?? 0)
        
        statusLabel.text = "Upcoming"
        dayValueLabel.text = String(format: "%02d", d)
        hourValueLabel.text = String(format: "%02d", h)
        minuteValueLabel.text = String(format: "%02d", m)
    }
}

/*extension CountdownView {

    func configure(status: String, date: Date, day: Int, hour: Int, minute: Int) {
        statusLabel.text = status
        dateLabel.text = "Date: " + DateFormatter.defaultDateFormat.string(from: date)

        (countdownStack.arrangedSubviews[0] as? UIStackView)?
            .arrangedSubviews.compactMap { $0 as UIView }.first?
            .subviews.compactMap { $0 as? UILabel }.first?.text = String(format: "%02d", day)

        (countdownStack.arrangedSubviews[1] as? UIStackView)?
            .arrangedSubviews.compactMap { $0 as UIView }.first?
            .subviews.compactMap { $0 as? UILabel }.first?.text = String(format: "%02d", hour)

        (countdownStack.arrangedSubviews[2] as? UIStackView)?
            .arrangedSubviews.compactMap { $0 as UIView }.first?
            .subviews.compactMap { $0 as? UILabel }.first?.text = String(format: "%02d", minute)
    }
}*/
