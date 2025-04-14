import 'package:flutter/material.dart';

class GenderDropdown extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderDropdown({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedGender?.isEmpty == true ? null : selectedGender,
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
        DropdownMenuItem(value: "Other", child: Text("Other")),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Select your gender",
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
