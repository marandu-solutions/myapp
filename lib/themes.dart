// lib/core/theme/themes.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Classe para centralizar todas as nossas cores e estilos customizados
class AppTheme {
  // Construtor privado para impedir que a classe seja instanciada
  AppTheme._();

  //--------------------------------------------------
  // 1. DEFINIÇÃO DAS CORES
  //--------------------------------------------------
  // Defina sua cor primária. O Material 3 irá gerar o restante da paleta a partir dela.
  static const Color _primaryColor = Color(0xFF0D63F3); // Um azul vibrante e moderno

  // Cores de Status
  static const Color colorSuccess = Color(0xFF28A745);
  static const Color colorWarning = Color(0xFFFFC107);
  static const Color colorError = Color(0xFFDC3545);

  // Cores Neutras (exemplo para o tema claro)
  static const Color _lightScaffoldBackgroundColor = Color(0xFFF7F8FC);
  static const Color _lightCardColor = Colors.white;
  static const Color _lightTextColor = Color(0xFF212121);

  // Cores Neutras (exemplo para o tema escuro)
  static const Color _darkScaffoldBackgroundColor = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);
  static const Color _darkTextColor = Color(0xFFFFFFFF);

  //--------------------------------------------------
  // 2. DEFINIÇÃO DE CONSTANTES DE DESIGN (Espaçamentos, Bordas)
  //--------------------------------------------------
  static const double cardElevation = 4.0;
  static const double borderRadius = 16.0;

  //--------------------------------------------------
  // 3. TEMA CLARO (LIGHT THEME)
  //--------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightScaffoldBackgroundColor,
    cardColor: _lightCardColor,

    // Esquema de Cores (gerado a partir da cor primária)
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      background: _lightScaffoldBackgroundColor,
    ),

    // Tipografia com Google Fonts
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 32, color: _lightTextColor),
      headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 24, color: _lightTextColor),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: _lightTextColor),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: _lightTextColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: _lightTextColor.withOpacity(0.7)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), // Para botões
    ),

    // Estilo dos Cards
    cardTheme: CardTheme(
      elevation: cardElevation,
      color: _lightCardColor,
      surfaceTintColor: Colors.transparent, // Impede que o card mude de cor com a elevação
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),

    // Estilo dos Botões Elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2.0,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),

    // Estilo dos Campos de Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(color: _lightTextColor.withOpacity(0.6)),
    ),

    // Estilo da AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: _lightScaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1.0, // Sombra suave quando a lista rola por baixo
      shadowColor: Colors.black.withOpacity(0.1),
      iconTheme: const IconThemeData(color: _lightTextColor),
      titleTextStyle: GoogleFonts.montserrat(
        color: _lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  //--------------------------------------------------
  // 4. TEMA ESCURO (DARK THEME)
  //--------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
    cardColor: _darkCardColor,

    // Esquema de Cores (gerado a partir da cor primária para o modo escuro)
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      background: _darkScaffoldBackgroundColor,
    ),

    // Tipografia (usamos a mesma base, apenas ajustando as cores)
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 32, color: _darkTextColor),
      headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 24, color: _darkTextColor),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: _darkTextColor),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: _darkTextColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: _darkTextColor.withOpacity(0.7)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), // Para botões
    ),

    // Estilo dos Cards para o tema escuro
    cardTheme: CardTheme(
      elevation: cardElevation,
      color: _darkCardColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),

    // Estilo dos Botões Elevados (pode ser o mesmo)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2.0,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),

    // Estilo dos Campos de Input para o tema escuro
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(color: _darkTextColor.withOpacity(0.6)),
    ),

    // Estilo da AppBar para o tema escuro
    appBarTheme: AppBarTheme(
      backgroundColor: _darkScaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black.withOpacity(0.2),
      iconTheme: const IconThemeData(color: _darkTextColor),
      titleTextStyle: GoogleFonts.montserrat(
        color: _darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}