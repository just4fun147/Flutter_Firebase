import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase/entity/employee.dart';
import 'package:firebase/inputPage.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(
        title: 'Firebase',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // //getData
  // List<Map<String, dynamic>> employee = [];
  // void refresh() async {
  //   final data = await SQLHelper.getEmployee();
  //   setState(() {
  //     employee = data;
  //   });
  // }

  @override
  void initState() {
    // refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("EMPLOYEE"),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InputPage(
                            title: 'INPUT EMPLOYEE',
                            id: null,
                            name: null,
                            email: null)),
                  );
                  // ).then((_) => refresh());
                }),
            IconButton(icon: Icon(Icons.clear), onPressed: () async {})
          ],
        ),
        body: StreamBuilder(
            stream: getEmployee(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Center(child: Text('Something went wrong'));
              }
              if (snapshot.hasData) {
                final employees = snapshot.data!;
                return ListView(
                  children: employees.map(buildEmployee).toList(),
                );
              } else {
                return Center(child: Text('NO DATA'));
              }
            }));
  }

  Widget buildEmployee(Employee employee) => Slidable(
        child: ListTile(
          title: Text(employee.name),
          subtitle: Text(employee.email),
        ),
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          IconSlideAction(
            caption: 'Update',
            color: Colors.blue,
            icon: Icons.update,
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InputPage(
                          title: 'INPUT EMPLOYEE',
                          id: employee.id,
                          name: employee.name,
                          email: employee.email,
                        )),
              );
              // .then((_) => refresh());
            },
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {
              final docEmployee = FirebaseFirestore.instance
                  .collection('employee')
                  .doc(employee.id);
              docEmployee.delete();
            },
          )
        ],
      );

  Stream<List<Employee>> getEmployee() => FirebaseFirestore.instance
      .collection('employee')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList());
}
