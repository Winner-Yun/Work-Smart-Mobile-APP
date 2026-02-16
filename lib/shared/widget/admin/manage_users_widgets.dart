import 'package:flutter/material.dart';

Widget infoChip(BuildContext context, String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.2),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

Widget statusChip(BuildContext context, String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget sectionTitle(BuildContext context, String title) {
  return Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

Widget infoCard(BuildContext context, {required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.1),
      ),
    ),
    child: Column(children: children),
  );
}

Widget detailRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildSectionLabel(BuildContext context, String label) {
  return Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
    ),
  );
}

Widget buildSectionLabelCreate(
  BuildContext context,
  String label,
  IconData icon,
) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ],
  );
}

Widget buildTextField(
  BuildContext context, {
  required String label,
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool readOnly = false,
  bool isSystemGenerated = false,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(
          color: isSystemGenerated
              ? colorScheme.onSurface.withOpacity(0.6)
              : colorScheme.onSurface,
          fontWeight: isSystemGenerated ? FontWeight.w500 : FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: readOnly ? colorScheme.outline : colorScheme.primary,
          ),
          filled: true,
          fillColor: readOnly
              ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
              : colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error.withOpacity(0.5)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    ],
  );
}

Widget buildDropdown(
  BuildContext context, {
  required String label,
  required String value,
  required List<String> items,
  required void Function(String?) onChanged,
  bool isStatus = false,
  String Function(String)? statusLabel,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  Color getStatusColor(String status) {
    if (status.toLowerCase() == 'active') return Colors.green;
    if (status.toLowerCase() == 'inactive') return Colors.orange;
    if (status.toLowerCase() == 'suspended') return Colors.red;
    return colorScheme.outline;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          prefixIcon: Icon(
            isStatus && value.isNotEmpty
                ? getStatusColor(value) == Colors.green
                      ? Icons.check_circle
                      : Icons.circle_outlined
                : Icons.business_sharp,
            size: 20,
            color: isStatus && value.isNotEmpty
                ? getStatusColor(value)
                : colorScheme.outline,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items.map((item) {
          String display;
          if (isStatus && statusLabel != null) {
            display = statusLabel(item);
          } else {
            display = item.length > 1
                ? item[0].toUpperCase() + item.substring(1)
                : item;
          }

          return DropdownMenuItem(value: item, child: Text(display));
        }).toList(),
      ),
    ],
  );
}
