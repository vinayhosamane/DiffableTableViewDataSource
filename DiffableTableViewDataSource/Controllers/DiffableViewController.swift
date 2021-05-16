//
//  ViewController.swift
//  DiffableTableViewDataSource
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//
import UIKit
import Combine

class DiffableViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let rowIdentifier = "someIdentifier"
    
    private lazy var datasource = makeDatasource()
    
    private lazy var viewModel = DiffableTableViewModel()
    
    var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableviewCells()
        
        setupBindings()
    
        // delay and update tableview
        self.update(with: self.viewModel.cards)
        
        // simulate remove from dataosurce
        let pickedSectionIndexIndex = Int.random(in: 0..<viewModel.cards.count)
        let pickedRowIndex = Int.random(in: 0..<viewModel.cards[pickedSectionIndexIndex].rows.count)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [unowned self] in
            self.remove(viewModel.cards[pickedSectionIndexIndex].rows[pickedRowIndex])
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //destory all subscriptions
        cancellables.forEach { (subscriber) in
            subscriber.cancel()
        }
    }
    
    private func setupBindings() {
        let publisher = viewModel.fetchCatalogCards()
        publisher
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
            if case .failure(let error) = completion {
                print("fetch error -- \(error)")
            }
        } receiveValue: { [weak self] cards in
            self?.update(with: cards)
        }.store(in: &cancellables)
    }
    
    private func setupTableviewCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: rowIdentifier)
        tableView.dataSource = datasource
        tableView.delegate = self
        
        tableView.rowHeight = 50.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = datasource.snapshot().sectionIdentifiers[section]
        
        let label = UILabel()
        label.text = sectionModel.title
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // on row selection
        let rowModel = datasource.snapshot().sectionIdentifiers[indexPath.section].rows[indexPath.row]
        print(rowModel)
    }

}

// all diffable dataosurce code
extension DiffableViewController {

    // create diffable tableview datasource
    private func makeDatasource() -> UITableViewDiffableDataSource<SectionModel, RowModel> {
        let reuseIdentifier = rowIdentifier
        
        return UITableViewDiffableDataSource<SectionModel, RowModel>(tableView: tableView) { tableView, indexPath, rowModel -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            cell.textLabel?.text = rowModel.name
            cell.detailTextLabel?.text = rowModel.detail
            return cell
        }
    }
    
    func update(with cards: [SectionModel], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, RowModel>()
        
        cards.forEach { (section) in
            snapshot.appendSections([section])
            snapshot.appendItems(section.rows, toSection: section)
        }

        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }
    
    func remove(_ card: RowModel, animate: Bool = true) {
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([card])
        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }

}
