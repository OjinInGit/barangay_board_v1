"""One-off patches for Barangay Board UI."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "lib"


def patch_main():
    p = ROOT / "main.dart"
    t = p.read_text(encoding="utf-8")
    if "FlutterQuillLocalizations" in t:
        return
    t = t.replace(
        "import 'package:flutter_localizations/flutter_localizations.dart';\n",
        "import 'package:flutter_localizations/flutter_localizations.dart';\n"
        "import 'package:flutter_quill/flutter_quill.dart';\n",
    )
    t = t.replace(
        """          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],""",
        """          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],""",
    )
    p.write_text(t, encoding="utf-8")


def patch_theme():
    p = ROOT / "core" / "theme" / "app_theme.dart"
    t = p.read_text(encoding="utf-8")
    if "google_fonts" in t:
        return
    t = t.replace(
        "import 'package:flutter/material.dart';\n",
        "import 'package:flutter/material.dart';\n"
        "import 'package:google_fonts/google_fonts.dart';\n",
    )
    t = t.replace(
        """    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: base.copyWith(""",
        """    final textTheme = GoogleFonts.sourceSans3TextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      colorScheme: base.copyWith(""",
        1,
    )
    t = t.replace(
        """    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: base,""",
        """    final textThemeDark = GoogleFonts.sourceSans3TextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textThemeDark,
      colorScheme: base,""",
        1,
    )
    p.write_text(t, encoding="utf-8")


if __name__ == "__main__":
    patch_main()
    patch_theme()
    print("patched")
