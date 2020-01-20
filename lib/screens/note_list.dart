import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import '../screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/selections.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  double reqPercentage = 75;
  double newPercent = 0;
  final date = DateTime.now();

  _changed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('percent', newPercent);
    });
    _save();
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      reqPercentage = prefs.getDouble('percent');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Attendace Tracker',
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              '${new DateFormat().add_MMMd().format(date)},${new DateFormat("EEEE").format(date)}',
              style: TextStyle(color: Colors.teal),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Selections.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
        /*actions: <Widget>[
          IconButton(
            tooltip: 'DELETE ALL SUBJECTS',
            icon: Icon(Icons.delete),
            onPressed: () {
              if (noteList != null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("DELETE ALL"),
                        content: Text(
                            'ARE YOU SURE YOU WANT TO DELETE ALL ENTRIES?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                            child: Text('Accept'),
                            onPressed: deleteListView,
                          )
                        ],
                      );
                    });
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('List already Empty'),
                        content: Text('No subjects to delete'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      );
                    });
              }
              /*debugPrint('Delete Clicked');
              deleteListView();*/
            },
          ),
          IconButton(
            tooltip: 'ADD NEW SUBJECT',
            icon: Icon(Icons.add),
            onPressed: () {
              debugPrint('FAB clicked');
              navigateToDetail(
                  Note('', 0, 0), 'Add Subject', reqPercentage);
            },
          ),
          IconButton(
            tooltip: 'EDIT ATTENDANCE REQUIRED',
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                        'Minimum attendace needed\nCurrent: $reqPercentage'),
                    content: TextField(
                      decoration: InputDecoration(
                        hintText: '$reqPercentage',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        newPercent = double.parse(value);
                        _changed();
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Text('Save'),
                        onPressed: newPercent != null
                            ? () {
                                setState(() {
                                  reqPercentage = newPercent;
                                  _save();
                                  updateListView();
                                });
                                Navigator.of(context).pop();
                              }
                            : null,
                      )
                    ],
                  );
                },
              );
            },
          )
        ],*/
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', 0, 0), 'Add Subject', reqPercentage);
        },
        tooltip: 'Add Subject',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    if (reqPercentage == null) {
      reqPercentage = 0;
      //_percentDialog();
    }
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        int total = this.noteList[position].total;
        int present =
            this.noteList[position].total - this.noteList[position].missed;
        double percent = ((present / total) * 100);
        return Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              side: new BorderSide(
                color: percent >= reqPercentage ? Colors.green : Colors.red,
                width: 5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.blueGrey,
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    /*leading: CircleAvatar(
                      backgroundColor:
                          Colors.blueAccent,
                    ),*/
                    title: Text(
                      this.noteList[position].title,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Attendance: $present/$total',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: animatedCircularChart(total, present),
                    /*GestureDetector(
                      child: Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _delete(context, noteList[position]);
                      },
                    ),*/
                    onTap: () {
                      debugPrint("ListTile Tapped");
                      navigateToDetail(this.noteList[position], 'Edit Subject',
                          reqPercentage);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    bottom: 10,
                  ),
                  child: numberOfLecturesRequired(total, present) >= 0
                      ? Text(
                          'You require ${numberOfLecturesRequired(total, present)} to complete attendance',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      : Text(
                          'You can bunk upto ${numberOfLecturesRequired(total, present) * (-1)} classes',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int numberOfLecturesRequired(int total, int present) {
    int a = 0;
    int x;
    if (reqPercentage == 100)
      x = a;
    else
      x = (((reqPercentage * 0.01) * total - present) /
              ((100 - reqPercentage) * 0.01))
          .ceil();
    int bunks = 0;
    int t = total + 1;
    if (x < 0) {
      while (x < 0) {
        x = (((reqPercentage * 0.01) * t - present) /
                ((100 - reqPercentage) * 0.01))
            .ceil();
        if (x <= 0) bunks++;
        t++;
      }
      return bunks * -1;
    }
    return x;
  }

  void navigateToDetail(Note note, String title, double reqPercentage) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title, reqPercentage);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void deleteListView() {
    databaseHelper.deleteAll();
    noteList = null;
    updateListView();
    Navigator.of(context).pop();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.reqPercentage = reqPercentage;
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  Widget animatedCircularChart(int total, int present) {
    final GlobalKey<AnimatedCircularChartState> _chartKey =
        new GlobalKey<AnimatedCircularChartState>();
    final _chartSize = const Size(80, 80);
    int print;
    if (total == 0)
      print = 0;
    else
      print = ((present / total) * 100).ceil();
    return new AnimatedCircularChart(
      key: _chartKey,
      size: _chartSize,
      initialChartData: <CircularStackEntry>[
        total == 0
            ? new CircularStackEntry(<CircularSegmentEntry>[
                new CircularSegmentEntry(100, Colors.white)
              ])
            : new CircularStackEntry(
                <CircularSegmentEntry>[
                  new CircularSegmentEntry(
                    (present / total) * 100,
                    ((present / total) * 100) >= reqPercentage
                        ? Colors.green
                        : Colors.red,
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
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }

  var text = new RichText(
    text: new TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: new TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        new TextSpan(text: 'Hello'),
        new TextSpan(
            text: '', style: new TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );


  void choiceAction(String choice) {
    if (choice == Selections.delete) {
      if (noteList != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("DELETE ALL"),
                content: Text('ARE YOU SURE YOU WANT TO DELETE ALL ENTRIES?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FlatButton(
                    child: Text('Accept'),
                    onPressed: deleteListView,
                  )
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('List already Empty'),
                content: Text('No subjects to delete'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    } else if (choice == Selections.add) {
      debugPrint('FAB clicked');
      navigateToDetail(Note('', 0, 0), 'Add Subject', reqPercentage);
    } else if (choice == Selections.edit) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Minimum attendace needed\nCurrent: $reqPercentage'),
            content: TextField(
              decoration: InputDecoration(
                hintText: '$reqPercentage',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                newPercent = double.parse(value);
                _changed();
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('Save'),
                onPressed: newPercent != null
                    ? () {
                        setState(() {
                          reqPercentage = newPercent;
                          _save();
                          updateListView();
                        });
                        Navigator.of(context).pop();
                      }
                    : null,
              )
            ],
          );
        },
      );
    }
  }
}
