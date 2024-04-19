import 'package:flutter/material.dart';
import 'package:bionexus_admin/templates.dart';

class PatientsQueuePage extends StatefulWidget {
  const PatientsQueuePage({super.key});

  @override
  State<PatientsQueuePage> createState() => _PatientsQueuePageState();
}

class _PatientsQueuePageState extends State<PatientsQueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
      onPressed: () => {},
      child: Icon(Icons.add),
    ));
  }
}
