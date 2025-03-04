import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class infoDialog extends StatefulWidget {

  String? title, description;

  infoDialog({super.key, this.title, this.description});

  @override
  State<infoDialog> createState() => _infoDialogState();
}

class _infoDialogState extends State<infoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.grey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 12,),

                Text(
                  widget.title.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 27,),

                Text(
                  widget.description.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54
                  ),
                ),

                const SizedBox(height: 32,),

                SizedBox(
                  width: 202,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Restart.restartApp();
                    },
                    child: const Text(
                      "OK"
                    ),
                  ),
                ),

                const SizedBox(height: 32,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
