import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool isSecret;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? onSubmit;
  final TextInputType keyboardType;
  final bool? enabled;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final int maxLength;

  const CustomTextField({
    Key? key,
    this.icon,
    required this.label,
    this.isSecret = false,
    this.inputFormatters,
    this.initialValue,
    this.readOnly = false,
    this.validator,
    this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmit,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onTap,
    this.onEditingComplete,
    this.onChanged,
    this.maxLength = 20,

  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();

    isObscure = widget.isSecret;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.keyboardType);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(

        onTap: widget.onTap,
        onChanged: widget.onChanged,
        focusNode: widget.focusNode,
        textInputAction: widget.nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (widget.nextFocusNode != null) {
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          } else {
            widget.focusNode!.unfocus();
            if (widget.onSubmit != null) {
              widget.onSubmit!();
            }
          }
        },
        onEditingComplete: widget.onEditingComplete,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        readOnly: widget.readOnly,
        initialValue: widget.initialValue,
        inputFormatters: widget.inputFormatters,
        obscureText: isObscure,
        validator: widget.validator,
        decoration: InputDecoration(
          prefixIcon: widget.icon !=null ? Icon(widget.icon): null,
          suffixIcon: widget.isSecret
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  icon:
                      Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                )
              : null,
          labelText: widget.label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
