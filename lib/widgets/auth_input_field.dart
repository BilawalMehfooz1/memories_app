import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  const AuthInput({
    super.key,
    required this.labelText,
  });
  final String labelText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              15), // adjust this value for desired roundness
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(
              15), // adjust this value for desired roundness
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
              color: Colors
                  .red), // adjust this color for when the field is focused
          borderRadius: BorderRadius.circular(
              15), // adjust this value for desired roundness
        ),
      ),
      // enableSuggestions: false,
      // validator: (value) {
      //   if (value == null || value.trim().length < 4 || value.isEmpty) {
      //     return 'Please enter at least 4 characters.';
      //   }
      //   return null;
      // },
      // onSaved: (newValue) {},
      // keyboardType: TextInputType.emailAddress,
    );
  }
}








