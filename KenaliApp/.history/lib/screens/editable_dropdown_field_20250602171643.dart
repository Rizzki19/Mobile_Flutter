import 'package:flutter/material.dart';

class DropdownOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String?) onChanged;
  final InputDecoration? decoration;

  const DropdownOnlyField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        InputDecorator(
          decoration: decoration ??
              const InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value.isEmpty ? null : value,
              hint: Text(
                'Pilih ${label.toLowerCase()}',
                style: const TextStyle(color: Colors.grey),
              ),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}