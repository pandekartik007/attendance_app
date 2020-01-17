import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import '../screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

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
  double newPercent;
  TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_changedValues);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _changedValues() {
    print('${_textEditingController.text}');
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
        title: Text('Attendace Tracker'),
        actions: <Widget>[
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
            icon: Icon(Icons.add),
            onPressed: () {
              debugPrint('FAB clicked');
              navigateToDetail(Note('', 0, 0), 'Add Subject');
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
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
                        },
                      ),
                   actions: <Widget>[
                      FlatButton(
                        child: Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Text('Save'),
                        onPressed: () {
                          reqPercentage = newPercent;
                          setState(() {
                            updateListView();
                          });
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                    
                  );
                },
                /*Slider(
                  min: 0,
                  max: 100,
                  divisions: 5,
                  value: reqPercentage,
                  onChanged: (newValue) {
                    setState(() {
                      reqPercentage=newValue;
                      updateListView();
                    });
                  },
                ),*/
              );
            },
          )
        ],
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', 0, 0), 'Add Subject');
        },
        tooltip: 'Add Subject',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        int total = this.noteList[position].total;
        int present =
            this.noteList[position].total - this.noteList[position].missed;
        int percent = ((present / total) * 100).ceil();
        return Padding(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              side: new BorderSide(
                color: percent >= reqPercentage ? Colors.green : Colors.red,
                width: 5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.blueAccent,
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
                      navigateToDetail(this.noteList[position], 'Edit Subject');
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
    int x = (((reqPercentage * 0.01) * total - present) / 0.25).ceil();
    int bunks = 0;
    int t = total + 1;
    if (x < 0) {
      while (x < 0) {
        x = (((reqPercentage * 0.01) * t - present) / 0.25).ceil();
        if (x <= 0) bunks++;
        t++;
      }
      return bunks * -1;
    }
    return x;
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
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
    int print = ((present / total) * 100).ceil();
    return new AnimatedCircularChart(
      key: _chartKey,
      size: _chartSize,
      initialChartData: <CircularStackEntry>[
        new CircularStackEntry(
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
}
