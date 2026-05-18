#!/usr/bin/env python3
"""Fix UI issues: center quantity buttons and show product images in cart."""

import re


# Fix 1: produktdetail_screen.dart - Separate buttons and stock text into different rows
def fix_detail_screen():
    path = "/Users/marceloruediger/code/thriftshop/frontend/lib/screens/produkte/produktdetail_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace the single Row with two rows: one for buttons (centered), one for stock text
    old_pattern = r"""(Row\(\s*mainAxisAlignment: MainAxisAlignment\.center,\s*children:\s*\[\s*// MINUS Button
                        SizedBox\(\s*width: 44,\s*height: 44,\s*child: OutlinedButton\(\s*onPressed: _menge > 1
                                \? \(\) \{
                                    setState\(\(\) \{
                                      _menge--;\s*\}\);
                                    \}\)
                                : null,\s*child: const Icon\(Icons\.remove\),\s*\),\s*\),\s*const SizedBox\(width: 16\),\s*// Mengenanzeige
                        Container\(\s*width: 60,\s*height: 44,\s*decoration: BoxDecoration\(\s*border: Border\.all\(color: Colors\.grey\[300\]!\),\s*borderRadius: BorderRadius\.circular\(8\),\s*\),\s*child: Center\(\s*child: Text\(\s*'\$_menge',\s*style: theme\.textTheme\.headlineSmall,\s*\),\s*\),\s*\),\s*const SizedBox\(width: 16\),\s*// PLUS Button
                        SizedBox\(\s*width: 44,\s*height: 44,\s*child: OutlinedButton\(\s*onPressed: _menge < widget\.produkt\.lagerbestand
                                \? \(\) \{
                                    setState\(\(\) \{
                                      _menge\+\+;\s*\}\);
                                    \}\)
                                : null,\s*child: const Icon\(Icons\.add\),\s*\),\s*\),\s*const SizedBox\(width: 16\),\s*// Verfügbare Stück
                        Text\(\s*'\$\{widget\.produkt\.lagerbestand\} Stück verfügbar',\s*style: theme\.textTheme\.bodySmall\?\.copyWith\(\s*color: Colors\.grey\[600\],\s*\),\s*\),\s*\],\s*\)\s*\,)"""

    new_code = """Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // MINUS Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _menge > 1
                                ? () {
                                    setState(() {
                                      _menge--;
                                    });
                                  }
                                : null,
                            child: const Icon(Icons.remove),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Mengenanzeige
                        Container(
                          width: 60,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$_menge',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // PLUS Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _menge < widget.produkt.lagerbestand
                                ? () {
                                    setState(() {
                                      _menge++;
                                    });
                                  }
                                : null,
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.produkt.lagerbestand} Stück verfügbar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),"""

    if old_pattern in content:
        print("Error: regex pattern not found as substring")
        return False

    # Let's use a simpler approach - search for the specific lines
    lines = content.split("\n")

    # Find the line with "// Menge-Auswahl" and work from there
    found = False
    for i, line in enumerate(lines):
        if "// Menge-Auswahl" in line:
            found = True
            # Find the Row that contains the quantity controls
            row_start = None
            for j in range(i, min(i + 20, len(lines))):
                if (
                    "Row(" in lines[j]
                    and "mainAxisAlignment: MainAxisAlignment.center" in lines[j + 1]
                ):
                    row_start = j
                    break
            break

    if not found or row_start is None:
        print("Could not find quantity Row")
        return False

    # Now find the end of this Row (matching brackets)
    bracket_count = 0
    row_end = None
    for j in range(row_start, len(lines)):
        for char in lines[j]:
            if char == "(":
                bracket_count += 1
            elif char == ")":
                bracket_count -= 1
        if bracket_count == 0 and j > row_start:
            row_end = j
            break

    if row_end is None:
        print("Could not find Row end")
        return False

    # Insert a new Row for the stock text after the existing Row
    new_rows = old_code + "\n" + new_code

    # Replace the original Row with two Rows
    lines = lines[:row_start] + new_rows.split("\n") + lines[row_end + 1 :]

    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Fixed: {path}")
    return True


# Fix 2: warenkorb_screen.dart - Show product images instead of icons
def fix_cart_screen():
    path = "/Users/marceloruediger/code/thriftshop/frontend/lib/screens/warenkorb/warenkorb_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    old_code = """leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: const Icon(Icons.image_outlined),
                        ),"""

    new_code = """leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: item.produkt.bildpfad != null
                                ? Image.asset(
                                    'assets/produktbilder/${item.produkt.bildpfad}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported_outlined);
                                    },
                                  )
                                : const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),"""

    if old_code in content:
        content = content.replace(old_code, new_code)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Fixed: {path}")
        return True
    else:
        print("Could not find CircleAvatar in werenkorb_screen.dart")
        return False


if __name__ == "__main__":
    print("Fixing UI issues...")
    fix_detail_screen()
    fix_cart_screen()
    print("Done!")
