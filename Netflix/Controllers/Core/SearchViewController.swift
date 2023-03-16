//
//  SearchViewController.swift
//  Netflix
//
//  Created by Aslıhan Gürkan on 15.02.2023.
//

import UIKit

class SearchViewController: UIViewController {

    private var titles: [Title] = [Title]()
    
    private let discoverTable: UITableView = {
       let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchController : UISearchController = {
       let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search Movie or Tv Series"
        //minimal -> translucent
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.backgroundColor = .systemBackground
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        fetchDiscoverMovies()
        
        // searchResultsUpdater -> Update the search results. This method gets called every time the user types anything into the search bar
        // must be added UISearchResultsUpdating protocol to use searchResultsUpdater
        searchController.searchResultsUpdater = self
        
    }
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: (title.original_name ?? title.original_title) ?? "Unknown Name" , posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let title = titles[indexPath.row]
            
            guard let titleName = title.original_title ?? title.original_name else { return }
            
            APICaller.shared.getMovie(with: titleName) { [weak self] result in
                switch result {
                case .success(let videoItem):
                    DispatchQueue.main.async {
                        let vc = PreviewViewController()
                        vc.configure(with: PreviewViewModel(title: titleName, youtubeView: videoItem, overview: title.overview ?? ""))
                        self?.navigationController?.pushViewController(vc, animated: true )
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// UISearchResultsUpdating -> Update search results based on information the user enters into the search bar.
extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        //TODO: explanation
        guard let query = searchBar.text,
              //trimmingCharacters() -> removes whitespace from string
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              // minimize the call (bigger than 3) ,if the search bar has 2 character, dont call the server or send anything to server
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    //make public titles in SearchResultsViewController to access
                    resultsController.titles = titles
                    resultsController.searchResultsCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    func searchResultsViewControllerDidTapItem(_ viewModel: PreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = PreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
