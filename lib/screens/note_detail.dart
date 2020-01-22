import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import '../utils/reusable_card.dart';
import '../utils//constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  final double reqPercentage;

  NoteDetail(this.note, this.appBarTitle,this.reqPercentage);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle,this.reqPercentage);
  }
}

class NoteDetailState extends State<NoteDetail> {
  int total;
  int missed;

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  double reqPercentage;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _validate = false;

  NoteDetailState(this.note, this.appBarTitle,this.reqPercentage);
  Widget animatedCircularChart(int total, int present) {
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        new GlobalKey<AnimatedCircularChartState>();
    int print;
    final _chartSize = const Size(150, 150);
    if(total>0)
      print = ((present / total) * 100).ceil();
    else
      print = 0;
    return new AnimatedCircularChart(
      key: _chartKey,
      size: _chartSize,
      initialChartData: <CircularStackEntry>[
        total==0 ? new CircularStackEntry(
          <CircularSegmentEntry>[
            new CircularSegmentEntry(100, Colors.white)
          ]
          ) :
        new CircularStackEntry(
          <CircularSegmentEntry>[
            new CircularSegmentEntry(
              (present / total) * 100,
              ((present / total)*100)>=reqPercentage ? Colors.green : Colors.red,
              rankKey: 'completed',
            ),
            new CircularSegmentEntry(
              (1 - (present / total)) * 100,
              Colors.white,
              rankKey: 'remaining',
            ),
          ],
          rankKey: 'progress',
        ),
      ],
      chartType: CircularChartType.Radial,
      percentageValues: true,
      holeLabel: '$print',
      labelStyle: new TextStyle(
        color: Colors.blueGrey[600],
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }
  /*void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }*/

  @override
  Widget build(BuildContext context) {
    //TextStyle textStyle = Theme.of(context).textTheme.title;
    total = note.total;
    missed = note.missed;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element
                /*ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }),
                ),*/

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(color: Colors.white, fontSize: 25,fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      _validate = value.length == 0;
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.green, fontSize: 25),
                        errorText: _validate ? 'Value Can\'t Be Empty' : null,
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green,width: 2),
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //Graph

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: animatedCircularChart(total, total - missed),
                ),

                //Total Lectures and missed Lectures

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: ReusableCard(
                        colour: kActiveCardColor,
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Total Lectures',
                              style: kLabelTextStyle,
                            ),
                            Text(
                              total.toString(),
                              style: kNumberTextStyle,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RoundIconButton(
                                  icon: FontAwesomeIcons.minus,
                                  onPressed: () {
                                    if (total > 0) {
                                      setState(() {
                                      if(total>missed)
                                        total--;
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text('ERROR'),
                                            content: Text('Missed lectures can\'t be more than total lectures'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Close'),
                                                onPressed: () => Navigator.of(context).pop(),
                                              )
                                            ],
                                          );}
                                        );
                                      }
                                    });
                                      updateTotal();
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                RoundIconButton(
                                  icon: FontAwesomeIcons.plus,
                                  onPressed: () {
                                    setState(() {
                                      total++;
                                    });
                                    updateTotal();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                      Expanded(
                          child: ReusableCard(
                        colour: kActiveCardColor,
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Missed Lectures',
                              style: kLabelTextStyle,
                            ),
                            Text(
                              missed.toString(),
                              style: kNumberTextStyle,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                RoundIconButton(
                                  icon: FontAwesomeIcons.minus,
                                  onPressed: () {
                                    setState(() {
                                      missed--;
                                    });
                                    updateMissed();
                                  },
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                RoundIconButton(
                                  icon: FontAwesomeIcons.plus,
                                  onPressed: () {
                                    setState(() {
                                      if(total>missed)
                                        missed++;
                                      else{
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text('ERROR'),
                                            content: Text('Missed lectures can\'t be more than total lectures'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Close'),
                                                onPressed: () => Navigator.of(context).pop(),
                                              )
                                            ],
                                          );}
                                        );
                                      }
                                    });
                                    updateMissed();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                // Number of lectures remaining
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    maxLines: null,
                    controller: descriptionController,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Notes for subject',
                        labelStyle: TextStyle(color: Colors.green, fontSize: 25),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,width: 2
                            ),
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                // Save and Delete
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Colors.white,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              titleController.text.isEmpty
                                  ? _validate = true
                                  : _validate = false;
                              debugPrint("Save button clicked");
                              if (_validate == true){
                                return null;
                              }
                              else if(missed>total)
                                _showAlertDialog('Status', 'Missed Lectures can\'t be more than total lectures');
                              else
                                _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Colors.white,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  /* // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }*/

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  void updateTotal() {
    note.total = total;
  }

  void updateMissed() {
    note.missed = missed;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Attendance updated successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Attendance');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Subject was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Subject Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Subject');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class RoundIconButton extends StatelessWidget {
  RoundIconButton({@required this.icon, @required this.onPressed});

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(icon),
      onPressed: onPressed,
      elevation: 0.0,
      constraints: BoxConstraints.tightFor(
        width: 56.0,
        height: 56.0,
      ),
      shape: CircleBorder(),
      fillColor: Color(0xFF4C4F5E),
    );
  }
}
