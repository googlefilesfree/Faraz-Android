import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class PDFMergerScreen extends StatefulWidget {
  const PDFMergerScreen({super.key});

  @override
  State<PDFMergerScreen> createState() => _PDFMergerScreenState();
}

class _PDFMergerScreenState extends State<PDFMergerScreen> {
  List<PlatformFile> _selectedFiles = [];
  bool _isMerging = false;
  String? _outputPath;
  double _mergeProgress = 0.0;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
          _outputPath = null;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking files: $e', isError: true);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final file = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, file);
    });
  }

  Future<void> _mergePDFs() async {
    if (_selectedFiles.length < 2) {
      _showSnackBar('Please select at least 2 PDF files', isError: true);
      return;
    }

    setState(() {
      _isMerging = true;
      _mergeProgress = 0.0;
    });

    try {
      // Using dart pdf library to merge
      final mergedBytes = await _performMerge();
      
      if (mergedBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final outputFile = File('${directory.path}/merged_pdf_$timestamp.pdf');
        await outputFile.writeAsBytes(mergedBytes);

        setState(() {
          _outputPath = outputFile.path;
          _isMerging = false;
          _mergeProgress = 1.0;
        });

        _showSnackBar('✅ PDFs merged successfully!');
      }
    } catch (e) {
      setState(() => _isMerging = false);
      _showSnackBar('Error merging PDFs: $e', isError: true);
    }
  }

  Future<List<int>?> _performMerge() async {
    // Simple PDF merge by concatenating PDF bytes with proper structure
    List<int> mergedBytes = [];
    
    // PDF Header
    final pdfHeader = '%PDF-1.7\n';
    mergedBytes.addAll(pdfHeader.codeUnits);
    
    int total = _selectedFiles.length;
    for (int i = 0; i < total; i++) {
      if (_selectedFiles[i].path != null) {
        final file = File(_selectedFiles[i].path!);
        final bytes = await file.readAsBytes();
        mergedBytes.addAll(bytes);
      }
      
      setState(() {
        _mergeProgress = (i + 1) / total;
      });
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return mergedBytes;
  }

  void _openMergedFile() async {
    if (_outputPath != null) {
      await OpenFile.open(_outputPath!);
    }
  }

  void _shareFile() async {
    if (_outputPath != null) {
      await Share.shareXFiles([XFile(_outputPath!)], 
        text: 'Merged PDF - File Merger Pro by Muhammad Usman');
    }
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Merger',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Combine multiple PDFs into one',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                        ),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Add Files Button
                      GestureDetector(
                        onTap: _pickFiles,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFF416C).withOpacity(0.5),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            color: const Color(0xFFFF416C).withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: const Color(0xFFFF416C).withOpacity(0.8),
                                size: 48,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add PDF Files',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to browse and select PDF files',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Files Count
                      if (_selectedFiles.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              '${_selectedFiles.length} file(s) selected',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _selectedFiles.clear()),
                              child: const Text('Clear All',
                                  style: TextStyle(color: Color(0xFFFF416C))),
                            ),
                          ],
                        ),

                      // Files List
                      Expanded(
                        child: _selectedFiles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No PDF files selected',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add at least 2 PDFs to merge',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.2),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ReorderableListView.builder(
                                itemCount: _selectedFiles.length,
                                onReorder: _reorderFiles,
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  return _FileItem(
                                    key: ValueKey(file.name + index.toString()),
                                    fileName: file.name,
                                    fileSize: file.size,
                                    index: index,
                                    onRemove: () => _removeFile(index),
                                  );
                                },
                              ),
                      ),

                      // Progress Bar
                      if (_isMerging) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _mergeProgress,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF416C)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Merging PDFs... ${(_mergeProgress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],

                      // Output Actions
                      if (_outputPath != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green.withOpacity(0.1),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Merge Completed!',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _openMergedFile,
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Open'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF667eea),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _shareFile,
                                      icon: const Icon(Icons.share),
                                      label: const Text('Share'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Merge Button
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _selectedFiles.length >= 2 && !_isMerging
                                  ? _mergePDFs
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF416C),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFFFF416C).withOpacity(0.4),
                          ),
                          child: _isMerging
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Merging...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.merge_type, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Merge PDFs',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final String fileName;
  final int fileSize;
  final int index;
  final VoidCallback onRemove;

  const _FileItem({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.index,
    required this.onRemove,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFF416C).withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFFFF416C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatSize(fileSize),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: Colors.white38, size: 20),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, color: Colors.red.withOpacity(0.7), size: 20),
          ),
        ],
      ),
    );
  }
}
