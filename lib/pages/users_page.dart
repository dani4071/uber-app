import 'package:admin_uber_web_panel/widgets/users_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/commom_methods.dart';


class usersPage extends StatefulWidget {

  static const String id = "\webPageUsers";

  const usersPage({super.key});

  @override
  State<usersPage> createState() => _usersPageState();
}

class _usersPageState extends State<usersPage> {

  commonMethod cMethod = commonMethod();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [

              /// title
              Container(
                alignment: Alignment.topRight,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "Manage Users",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              /// table title
              Row(
                children: [
                  cMethod.header(2, 'USER ID'),
                  cMethod.header(1, 'USER NAME'),
                  cMethod.header(1, 'USER EMAIL'),
                  cMethod.header(1, 'PHONE'),
                  cMethod.header(1, 'ACTION'),
                ],
              ),

              /// user data list
              const usersDataList(),
            ],
          ),
        )
    );
  }
}
