//
//  FilterViewModel.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 9.10.2025.
//

import Foundation

protocol FilterViewModelProtocol: AnyObject {
    
    // Inputs
    func setSelected(_ status: LaunchStatusFilter)
    func setSearchText(_ text: String)
    func tapFilter()
    
    // Outputs
    var onStatusChanged: ((LaunchStatusFilter) -> Void)? { get set }
    var onSearchChanged: ((String) -> Void)? { get set }
    var onFilterTapped: (() -> Void)? { get set }
    
    var currentStatus: LaunchStatusFilter { get }
    var currentSearch: String { get }
}

final class FilterViewModel: FilterViewModelProtocol {
    
    // State
    private(set) var currentStatus: LaunchStatusFilter = .upcoming
    private(set) var currentSearch: String = ""
    
    // Outputs
    var onStatusChanged: ((LaunchStatusFilter) -> Void)?
    var onSearchChanged: ((String) -> Void)?
    var onFilterTapped: (() -> Void)?
    
    // Inputs
    func setSelected(_ status: LaunchStatusFilter) {
        guard currentStatus != status else { return }
        
        currentStatus = status
        onStatusChanged?(status)
    }
    
    func setSearchText(_ text: String) {
        guard currentSearch != text else { return }
        
        currentSearch = text
        onSearchChanged?(text)
    }
    
    func tapFilter() { onFilterTapped?() }
}
