import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PDFEditorScreen extends StatefulWidget {
  const PDFEditorScreen({super.key});

  @override
  State<PDFEditorScreen> createState() => _PDFEditorScreenState();
}

class _PDFEditorScreenState extends State<PDFEditorScreen> {
  String? _pdfPath;
  String? _fileName;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = false;
  PDFViewController? _pdfViewController;

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.first.path != null) {
        setState(() {
          _pdfPath = result.files.first.path;
          _fileName = result.files.first.name;
          _isLoading = true;
          _currentPage = 0;
          _totalPages = 0;
        });
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e', isError: true);
    }
  }

  void _goToPage(int page) {
    _pdfViewController?.setPage(page);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _shareFile() async {
    if (_pdfPath != null) {
      await Share.shareXFiles([XFile(_pdfPath!)],
          text: 'Shared from File Merger Pro by Muhammad Usman');
    }
  }

  void _showPageDialog() {
    final controller = TextEditingController(text: '${_currentPage + 1}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Go to Page', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Page number (1 - $_totalPages)',
            labelStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF667eea)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _goToPage(page - 1);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea)),
            child: const Text('Go', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PDF Viewer',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            _fileName ?? 'Open a PDF file',
                            style:
                                const TextStyle(fontSize: 12, color: Colors.white54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_pdfPath != null) ...[
                      GestureDetector(
                        onTap: _shareFile,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.share,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                        ),
                      ),
                      child: const Icon(Icons.edit_document,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _pdfPath == null
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                PDFView(
                                  filePath: _pdfPath!,
                                  enableSwipe: true,
                                  swipeHorizontal: false,
                                  autoSpacing: false,
                                  pageFling: false,
                                  onRender: (pages) {
                                    setState(() {
                                      _totalPages = pages ?? 0;
                                      _isLoading = false;
                                    });
                                  },
                                  onViewCreated: (controller) {
                                    _pdfViewController = controller;
                                  },
                                  onPageChanged: (page, total) {
                                    setState(() {
                                      _currentPage = page ?? 0;
                                      _totalPages = total ?? 0;
                                    });
                                  },
                                  onError: (error) {
                                    _showSnackBar('Error: $error', isError: true);
                                    setState(() => _isLoading = false);
                                  },
                                ),
                                if (_isLoading)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xFF4776E6)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Page Controls
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              border: Border(
                                top: BorderSide(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: _currentPage > 0
                                      ? () => _goToPage(_currentPage - 1)
                                      : null,
                                  icon: const Icon(Icons.arrow_back_ios,
                                      color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: _showPageDialog,
                                  child: Text(
                                    'Page ${_currentPage + 1} of $_totalPages',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _currentPage < _totalPages - 1
                                      ? () => _goToPage(_currentPage + 1)
                                      : null,
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // Open PDF Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _pickPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4776E6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                      shadowColor: const Color(0xFF4776E6).withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.file_open, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _pdfPath == null ? 'Open PDF File' : 'Open Another PDF',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined,
              size: 100, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text(
            'No PDF Opened',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to open a PDF file',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
          const SizedBox(height: 30),
          const _FeatureBadge(icon: '👁️', text: 'View PDF pages'),
          const _FeatureBadge(icon: '📑', text: 'Navigate between pages'),
          const _FeatureBadge(icon: '📤', text: 'Share your PDF'),
          const _FeatureBadge(icon: '🔍', text: 'Pinch to zoom'),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }
}
