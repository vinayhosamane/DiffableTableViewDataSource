# DiffableTableViewDataSource
This project is created to evaluate new tableview diffable dataosurce API, UITableViewDiffableDataSource. Available only in iOS13 +

![DiffableDoatasource Demo-high](https://user-images.githubusercontent.com/12964593/118347868-e434fe00-b563-11eb-9092-e3c74920ca0c.gif)

## Availability
iOS 13 and later

## History
If you worked on tableview, then you must have come across this famous error on your console.

**
'NSInternalInconsistencyException', reason: 'Invalid update: invalid number of rows in section 0. The number of rows contained in an existing section after the update (2) must be equal to the number of rows contained in that section before the update (2), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).'
**

When this error appears on your console, you would have even searched this error in your browser !!

Well this is due to inconsistency with your datasource.
Solution is to first update  your datasource model, then apply insert or delete operations on the cached tableview datasource with respect to updates indexes.
Even though you know the solution, this scenario will happen un-knowingly and error prone, since you have to know when to update or invalidate the datasource.
May of us would have taken the easy solution, 'tableview reloadData' when you found the complexity in just reloading specific row or section, inserting new rows to the section, or deleting complete section from the tableview.

Yup! You guessed it right. We have this sweet solution in our app.

## Future
Now to solve the above issue, apple has introduced a new datasource api in iOS13, which can be used with either tableview or collectionView. And this api is smart enough to identify the differences between your old and new datasources into the tableview.
Using UITableViewDiffableDataSource or UICollectionViewDiffableDataSource, would solve most of tableview nightmares..
As for our requirement, let's just focus on tableview diffable datasource.

## Implementation
As you know UITableView provides protocols for datasource and delegate. Let's just focus on datasource here. 
UITableViewDataSource, a protocol which defines api's to prepare data for the tableview. The consuming view controller or tableview controller should implement those protocol methods.
with the introduction of new diffable datasource UITableViewDiffableDataSource, these old datasource api's become obsolete.

@available(iOS 2.0, *) func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:

// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
@available(iOS 2.0, *) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell

@available(iOS 2.0, *) optional func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented 
.
.
.
etc, please check apple documentation.

## Diffable Datasource API

```
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
```
  
In old tableview, you would have set the datasource to self. So that the view controller has to implement those datasource api's.

In the diffable datasource, we have to create a UITableViewDifableDataSource<<Section Where Hashable>, < Row Where Hashable>, <Cell Provider where UITableViewCell>>
  
 1. Section where Hashable, a first argument to identify our section types in the datasource. We can create any data structure, but it should conform to Hashable protocol, so that iOS code internally uniquely identifies each section.

If we use default data types like enum, it by default conforms to hashable protocol. But if we use custom data types like our section model struct, then we should confirm to hashable protocol and implement

func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId) // here you can use any value, which helps you to uniquely identify this data type.
    }

 2. Row where Hashable, it is again same as section. It is used to identity rows in the datasource.
Cell Provider where UITableViewCell, as opposed to old approach, where we used cellForRow to dequeue a row and configure it with data. In this cellProvider, we write a closure which request tableview cell and configures with the row model.

To update the datasource with new data or model,

```
// update  datasource with new items
 func update(with cardsViewModel: CatalogCardsViewModel, animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, RowModel>()
        cardsViewModel.cards.forEach { (section) in
            snapshot.appendSections([section])
            snapshot.appendItems(section.rows, toSection: section)
        }
        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }

```

```
// delete items from datasource
    func remove(_ card: RowModel, animate: Bool = true) {
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([card])
        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }
```
 
We can use snapshot to update datasource, if it is for the first time, then create a snapshot and apply it to tableview datasource.
If the snapshot is already there, then get the snapshot from the datasource and update it by either adding removing section/row items.
