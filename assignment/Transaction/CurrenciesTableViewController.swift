//
//  CurrenciesTableViewController.swift
//  assignment
//
//  Created by 欧高远 on 6/5/2022.
//

import UIKit

class CurrenciesTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let REQUEST_STRING = "https://exchangerate-api.p.rapidapi.com/rapid/latest/AUD"
    weak var databaseController: DatabaseProtocol?
    let CURRENCY_CELL = "Currency"
    var currencies = [CurrencyData]()
    var filteredCurrencies = [CurrencyData]()
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        indicator.startAnimating()

        Task{
            
            await getExchangeRate()
        }

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else{
            return
        }
        
        if searchText.count > 0 {
            filteredCurrencies = currencies.filter({(currency: CurrencyData) -> Bool in return
                (currency.name?.lowercased().contains(searchText) ?? false) || (currency.code?.lowercased().contains(searchText) ?? false)
            })
        }
        tableView.reloadData()

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
       filteredCurrencies.removeAll()
        filteredCurrencies = currencies
        
    }
    
    //show cancel button when user is starting to search
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    //hide cancel button when user clicks cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    //send the request to get all exchange rates for different currencies
    func getExchangeRate() async{
        let headers = [
            "X-RapidAPI-Host": "exchangerate-api.p.rapidapi.com",
            "X-RapidAPI-Key": Bundle.main.infoDictionary!["API_KEY"] as! String
        ]
        
        guard let requestURL = URL(string: REQUEST_STRING) else{
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = "GET"
        
        do{
            let (data, _) = try await
            URLSession.shared.data(for: urlRequest)
            

            
            let decoder = JSONDecoder()
            let exchangeRateData = try decoder.decode(ExchangeRateData.self, from:data)
            //get dictionary of currency
            let exchangeRateDic = exchangeRateData.rates
            let exchangeRateKeys = exchangeRateData.rates?.keys.sorted()
            
            //store the currency
            for key in exchangeRateKeys!{
                let locale = NSLocale.autoupdatingCurrent
                guard let name = locale.localizedString(forCurrencyCode: key) else {
                    
                    continue
                }
                
                let newCurrency = CurrencyData(name: name, rate: exchangeRateDic?[key] ?? 0, code: key)
                currencies.append(newCurrency)
                
                DispatchQueue.main.async {
                self.filteredCurrencies = self.currencies
                self.tableView.reloadData()
                self.indicator.stopAnimating()

                }
            }
        }
        catch let error{
            print(error)
            navigationController?.popViewController(animated: true)

            displayMessage(title: "NO Internet Conncection", message: "Please Check Your Internet Connection")
            
        }
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredCurrencies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CURRENCY_CELL, for: indexPath)
        // Configure the cell...
        let currency = filteredCurrencies[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(currency.name!) (\(currency.code!))"
        content.secondaryText = currency.rate?.description
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //store the currency in NotificationCenter
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Currency"), object: filteredCurrencies[indexPath.row])
        navigationController?.popViewController(animated: true)

       
    }

  

}
