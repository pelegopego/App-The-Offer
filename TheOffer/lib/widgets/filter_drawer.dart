import 'package:flutter/material.dart';
import 'package:theoffer/models/category.dart';

class FilterDrawer extends StatefulWidget {
  Function getSortingData;
  Function onSubCatPressed;
//  List<Widget> subCatList;
  List<Category> categoryList = [];
  Function getSubCat;
  Map<int, List<Widget>> subCatList;
  FilterDrawer(
    this.getSortingData,
    this.categoryList,
    this.subCatList,
    this.getSubCat,
  );
  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  List filterItems = [
    "Novos",
    "Média de avaliação dos compradores",
    "Mais vistos",
    "A até Z",
    "Z até A"
  ];
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in filterItems) {
      items.add(new DropdownMenuItem(
          value: city,
          child: Text(
            city,
            style: TextStyle(color: Colors.black),
          )));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 3.0,
            child: Container(
                alignment: Alignment.centerLeft,
                color: Colors.orange,
                height: 180.0,
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        'Ordenar por:  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.principalTheOffer,
                            fontSize: 18.0),
                      ),
                      DropdownButton(
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                        value: _currentItem,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.principalTheOffer,
                        ),
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      )
                    ],
                  ),
                )),
          ),
          Expanded(
            child: Theme(
                data: ThemeData(primarySwatch: Colors.secundariaTheOffer),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return ExpansionTile(
                        onExpansionChanged: (value) {
                          if (value) {
                            widget.getSubCat(index);
                          }
                        },
                        title: Text(widget.categoryList[index].name),
                        children: widget.subCatList[index]);
                  },
                  itemCount: widget.categoryList.length,
                )),
          ),
        ],
      ),
    );
  }
  
  void changedDropDownItem(String selectedCity) {
    String sortingWith = '';
    setState(() {
      _currentItem = selectedCity;
      switch (_currentItem) {
        case 'Novos':
          sortingWith = 'updated_at+asc';
          break;
        case 'Média de avaliação dos compradores':
          sortingWith = 'avg_rating+desc ';
          break;
        case 'Mais vistos':
          sortingWith = 'reviews_count+desc';
          break;
        case 'A até Z':
          sortingWith = 'name+asc';
          break;
        case 'Z até A':
          sortingWith = 'name+desc';
          break;
      }
      widget.getSortingData(sortingWith);
    });
  }
}
