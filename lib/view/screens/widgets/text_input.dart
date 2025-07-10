import 'package:flutter/material.dart';
import 'package:spanky/constrain.dart';

class TextInputField extends StatelessWidget {
  // final - Jab Aapko Pata ho ki ye ab change nahi hoga - const But Widgets/Methods Ke Liye
  final TextEditingController controller;
  final  IconData myIcon;
  final String myLabelText;
  final bool toHide;
  const TextInputField({super.key ,
  required this.controller,
    required this.myIcon,
    required this.myLabelText,
    this.toHide = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: toHide,
      controller: controller,
      decoration: InputDecoration(
        icon: Icon(myIcon),

        labelText: myLabelText,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: bordercolor,
            )),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: bordercolor,
        ), ),

      ),


    );
  }
}