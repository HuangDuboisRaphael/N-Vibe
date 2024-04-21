//
//  SearchLocationViewController.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import UIKit
import MapKit

final class SearchLocationViewController: UIViewController {
    // MARK: Properties and UIView.
    let viewModel: SearchLocationViewModelRepresentable
    let isSearchingArrival: Bool
    private var searchCompleter = MKLocalSearchCompleter()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: view.bounds, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        view.searchBarStyle = .prominent
        view.searchTextField.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Initialization.
    init(viewModel: SearchLocationViewModelRepresentable, isSearchingArrival: Bool) {
        self.viewModel = viewModel
        self.isSearchingArrival = isSearchingArrival
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewController life cycle methods.
extension SearchLocationViewController {
    override func loadView() {
        super.loadView()
        addLayouts()
        makeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // To display the keyboard when view appears.
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.removeCoordinator()
    }
}

// MARK: - Private properties.
private extension SearchLocationViewController {
    func addLayouts() {
        view.backgroundColor = .white
        navigationItem.setHidesBackButton(true, animated: true)
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpCell(_ cell: UITableViewCell, for result: MKLocalSearchCompletion) {
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
    }
}

// MARK: - Delegate and DataSource properties.
extension SearchLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

extension SearchLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        viewModel.searchResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        viewModel.errorResultingClosingView()
    }
}

extension SearchLocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let singleResult = viewModel.getSingleResult(at: indexPath)
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        setUpCell(cell, for: singleResult)
        return cell
    }
}

extension SearchLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.getPlacemarkInformation(at: indexPath, isSearchingArrival: isSearchingArrival)
    }
}
