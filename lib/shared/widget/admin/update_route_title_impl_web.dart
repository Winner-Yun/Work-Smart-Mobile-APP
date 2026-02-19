import 'dart:html' as html;

import 'package:flutter/material.dart';

void updateDocumentTitle(String title) {
  try {
    html.document.title = title;
  } catch (e) {
    debugPrint('Failed to update web title: $e');
  }
}
