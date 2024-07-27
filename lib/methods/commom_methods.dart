import 'package:flutter/material.dart';

class commonMethod {

  Widget header(int headerFlexValue, String headerTitle) {
    return Expanded(
      flex: headerFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.blueAccent.shade200,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            headerTitle,
            style: const TextStyle(
                color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

/// reason we returned widget here was so we could use image as well as use text
  Widget data(int dataFlexValue, Widget widget) {
    return Expanded(
      flex: dataFlexValue,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.grey,
        ),
        child: widget
      ),
    );
  }

}