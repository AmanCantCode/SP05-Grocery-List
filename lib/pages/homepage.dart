import 'package:flutter/material.dart';
import 'package:sp_grocery_list/pages/grocery_list/all_groups_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Colors.white,
    //   child: Center(
    //     child: Text("Home Page \n(where user selects their group and views the grocery list)",
    //       style: TextStyle(fontSize: 25),
    //       textAlign: TextAlign.center,),
    //   ),
    // );

    return(
    GroupsPage()
    );
  }
}

