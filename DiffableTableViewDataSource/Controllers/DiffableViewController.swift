//
//  ViewController.swift
//  DiffableTableViewDataSource
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//
import UIKit

class DiffableViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let rowIdentifier = "someIdentifier"
    
    private lazy var datasource = makeDatasource()
    
    private lazy var viewModel = DiffableTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableviewCells()
    
        // delay and update tableview
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [unowned self] in
            self.update(with: self.viewModel)
        }
        
        // delay and update tableview
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [unowned self] in
            self.remove(RowModel(name: "Nitin", detail: "xxx@gmail.com", type: .A))
        }
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
        let sectionModel = viewModel.cards[section]
        
        let label = UILabel()
        label.text = sectionModel.title
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // on row selection
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
    
    func update(with cardsViewModel: DiffableTableViewModel, animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, RowModel>()
        
        cardsViewModel.cards.forEach { (section) in
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
