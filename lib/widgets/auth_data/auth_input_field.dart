import 'package:flutter/material.dart';

class AuthInput extends StatefulWidget {
  const AuthInput({
    super.key,
    required this.labelText,
    required this.keyboardType,
    required this.obsecureText,
    required this.validator,
    required this.onSaved,
  });

  final bool obsecureText;
  final String labelText;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      keyboardType: widget.keyboardType,
      obscureText: widget.obsecureText && !_isVisible,
      style: TextStyle(
        color: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black, // Set text color based on theme
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: 13,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black, // Set label text color based on theme
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 220, 220, 220)),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: widget.obsecureText
            ? IconButton(
                icon:
                    Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
              )
            : null,
      ),
      onSaved: widget.onSaved,
      validator: widget.validator,
    );
  }
}
