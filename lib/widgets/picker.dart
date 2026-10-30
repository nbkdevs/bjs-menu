import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

const _placeholder = {'main': 'Select a main', 'side': 'Add a side', 'drink': 'Add a drink', 'dessert': 'Add a dessert'};

/// Searchable, category-grouped item list — the app version of the site's custom dropdown.
Future<MenuItem?> pickItem(BuildContext context, String role, {String? selectedId}) {
  return showModalBottomSheet<MenuItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      maxChildSize: .95,
      builder: (ctx, scroll) => _Picker(role: role, selectedId: selectedId, scroll: scroll),
    ),
  );
}

class _Picker extends StatefulWidget {
  final String role;
  final String? selectedId;
  final ScrollController scroll;
  const _Picker({required this.role, required this.selectedId, required this.scroll});

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final items = Menu.items.where((i) => i.role == widget.role && i.name.toLowerCase().contains(q.toLowerCase())).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final groups = <String, List<MenuItem>>{};
    for (final i in items) {
      groups.putIfAbsent(i.category, () => []).add(i);
    }
    final cats = groups.keys.toList()..sort();
    final rows = <Widget>[
      for (final c in cats) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Text(c.toUpperCase(), style: eyebrow(c: C.faint)),
        ),
        for (final i in groups[c]!) _row(i),
      ],
    ];
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_placeholder[widget.role]!, style: serif(22)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: 'Search ${rolePlural[widget.role]!.toLowerCase()}',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: C.field,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ]),
      ),
      Expanded(
        child: rows.isEmpty
            ? const Center(child: Text('No items match your search.'))
            : ListView(controller: widget.scroll, padding: const EdgeInsets.only(bottom: 24), children: rows),
      ),
    ]);
  }

  Widget _row(MenuItem i) {
    final sel = i.id == widget.selectedId;
    return Material(
      color: sel ? C.redTint : Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            ItemThumb(i.img, i.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink)),
                Text(i.calLabel, style: const TextStyle(fontSize: 13, color: C.muted)),
              ]),
            ),
            if (sel) const Icon(Icons.check_circle, color: C.red),
          ]),
        ),
      ),
    );
  }
}
