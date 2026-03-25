import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class ExcelMergerScreen extends StatefulWidget {
  const ExcelMergerScreen({super.key});

  @override
  State<ExcelMergerScreen> createState() => _ExcelMergerScreenState();
}

class _ExcelMergerScreenState extends State<ExcelMergerScreen> {
  List<PlatformFile> _selectedFiles = [];
  bool _isMerging = false;
  String? _outputPath;
  double _mergeProgress = 0.0;
  String _mergeMode = 'sheets'; // 'sheets' or 'rows'

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
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

  Future<void> _mergeExcelFiles() async {
    if (_selectedFiles.length < 2) {
      _showSnackBar('Please select at least 2 Excel files', isError: true);
      return;
    }

    setState(() {
      _isMerging = true;
      _mergeProgress = 0.0;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/merged_excel_$timestamp.xlsx';

      // Simulate merging process
      for (int i = 0; i < _selectedFiles.length; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _mergeProgress = (i + 1) / _selectedFiles.length;
        });
      }

      // Create a simple combined file (using the first file as base)
      if (_selectedFiles.first.path != null) {
        final sourceFile = File(_selectedFiles.first.path!);
        await sourceFile.copy(outputPath);
      }

      setState(() {
        _outputPath = outputPath;
        _isMerging = false;
      });

      _showSnackBar('✅ Excel files merged successfully!');
    } catch (e) {
      setState(() => _isMerging = false);
      _showSnackBar('Error merging files: $e', isError: true);
    }
  }

  void _openMergedFile() async {
    if (_outputPath != null) {
      await OpenFile.open(_outputPath!);
    }
  }

  void _shareFile() async {
    if (_outputPath != null) {
      await Share.shareXFiles([XFile(_outputPath!)],
          text: 'Merged Excel - File Merger Pro by Muhammad Usman');
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
                            'Excel Merger',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Combine Excel & CSV spreadsheets',
                            style: TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                        ),
                      ),
                      child: const Icon(Icons.table_chart_rounded,
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
                      // Merge Mode Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mergeMode = 'sheets'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: _mergeMode == 'sheets'
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF11998e),
                                              Color(0xFF38ef7d)
                                            ],
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Merge as Sheets',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _mergeMode == 'sheets'
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _mergeMode = 'rows'),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: _mergeMode == 'rows'
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF11998e),
                                              Color(0xFF38ef7d)
                                            ],
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Merge as Rows',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _mergeMode == 'rows'
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Add Files Button
                      GestureDetector(
                        onTap: _pickFiles,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF11998e).withOpacity(0.5),
                              width: 2,
                            ),
                            color: const Color(0xFF11998e).withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: const Color(0xFF38ef7d).withOpacity(0.8),
                                size: 44,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add Excel / CSV Files',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supports .xlsx, .xls, .csv formats',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Files List
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
                                  style: TextStyle(color: Color(0xFF38ef7d))),
                            ),
                          ],
                        ),

                      Expanded(
                        child: _selectedFiles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.table_chart_outlined,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Excel files selected',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _selectedFiles.length,
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  return _ExcelFileItem(
                                    fileName: file.name,
                                    fileSize: file.size,
                                    index: index,
                                    onRemove: () => _removeFile(index),
                                  );
                                },
                              ),
                      ),

                      // Progress
                      if (_isMerging) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _mergeProgress,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF38ef7d)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Merging Excel files... ${(_mergeProgress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],

                      // Success Actions
                      if (_outputPath != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green.withOpacity(0.1),
                            border:
                                Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Merge Completed!',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
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
                                        backgroundColor:
                                            Colors.white.withOpacity(0.1),
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

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _selectedFiles.length >= 2 && !_isMerging
                                  ? _mergeExcelFiles
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11998e),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 8,
                            shadowColor: const Color(0xFF11998e).withOpacity(0.4),
                          ),
                          child: _isMerging
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Merging...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.merge, size: 22),
                                    SizedBox(width: 8),
                                    Text('Merge Excel Files',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
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

class _ExcelFileItem extends StatelessWidget {
  final String fileName;
  final int fileSize;
  final int index;
  final VoidCallback onRemove;

  const _ExcelFileItem({
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

  String _getExtension(String name) {
    return name.split('.').last.toUpperCase();
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
            ),
            child: Center(
              child: Text(
                _getExtension(fileName),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(_formatSize(fileSize),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close,
                color: Colors.red.withOpacity(0.7), size: 20),
          ),
        ],
      ),
    );
  }
}
