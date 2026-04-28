import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class PdfPageManagerScreen extends StatefulWidget {
  final String pdfPath;
  final String docName;

  const PdfPageManagerScreen({
    super.key,
    required this.pdfPath,
    required this.docName,
  });

  @override
  State<PdfPageManagerScreen> createState() => _PdfPageManagerScreenState();
}

class _PdfPageManagerScreenState extends State<PdfPageManagerScreen> {
  final ctrl = Get.find<AppController>();
  late PdfDocument _document;
  List<int> _selectedPages = [];   // halaman yang MAU DIHAPUS
  bool _isLoading = true;
  int _totalPages = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _document = await PdfDocument.openFile(widget.pdfPath);
      setState(() {
        _totalPages = _document.pages.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _togglePage(int pageNum) {
    setState(() {
      if (_selectedPages.contains(pageNum)) {
        _selectedPages.remove(pageNum);
      } else {
        _selectedPages.add(pageNum);
      }
    });
  }

  Future<void> _deleteSelectedPages() async {
    if (_selectedPages.isEmpty) return;
    final isId = ctrl.locale.languageCode == 'id';

    // Konfirmasi hapus
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isId ? 'Hapus Halaman?' : 'Delete Pages?'),
        content: Text(isId
            ? 'Hapus ${_selectedPages.length} halaman yang dipilih?'
            : 'Delete ${_selectedPages.length} selected pages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isId ? 'Batal' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isId ? 'Hapus' : 'Delete',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      // Buat PDF baru tanpa halaman yang dihapus
      final keepPages = List.generate(_totalPages, (i) => i + 1)
          .where((p) => !_selectedPages.contains(p))
          .toList();

      if (keepPages.isEmpty) {
        // Kalau semua halaman dihapus, hapus dokumen ini
        ctrl.removeScannedDoc(_getDocId());
        Navigator.pop(context);
        return;
      }

      // Render halaman yang dipertahankan jadi gambar, simpan ke PDF baru
      final dir = await getTemporaryDirectory();
      final newPath = '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Simpan sebagai ScannedDocument baru per halaman
      for (int i = 0; i < keepPages.length; i++) {
        final pageNum = keepPages[i];
        final page = _document.pages[pageNum - 1];
        final image = await page.render(
          width: (page.width * 2).toInt(),
          height: (page.height * 2).toInt(),
        );
        if (image == null) continue;

        final imgPath = '${dir.path}/page_${pageNum}_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(imgPath).writeAsBytes(image.pixels);

        final doc = ScannedDocument(
          id: const Uuid().v4(),
          imagePath: imgPath,
          name: '${widget.docName} - Hal $pageNum',
          order: ctrl.scannedDocs.length + i,
        );
        ctrl.addScannedDoc(doc);
      }

      // Hapus dokumen PDF asli
      ctrl.removeScannedDoc(_getDocId());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isId
              ? '${_selectedPages.length} halaman berhasil dihapus!'
              : '${_selectedPages.length} pages deleted!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _getDocId() {
    return ctrl.scannedDocs
        .firstWhere((d) => d.imagePath == widget.pdfPath,
            orElse: () => ScannedDocument(id: '', imagePath: ''))
        .id;
  }

  @override
  Widget build(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docName),
        actions: [
          if (_selectedPages.isNotEmpty)
            TextButton.icon(
              onPressed: _isProcessing ? null : _deleteSelectedPages,
              icon: const Icon(Icons.delete, color: AppColors.error),
              label: Text(
                '${_selectedPages.length} ${isId ? "Hapus" : "Delete"}',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _isProcessing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(isId ? 'Memproses...' : 'Processing...'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Info bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: AppColors.primary.withOpacity(0.08),
                      child: Text(
                        isId
                            ? 'Ketuk halaman untuk menandai yang akan dihapus'
                            : 'Tap pages to mark for deletion',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Grid halaman PDF
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _totalPages,
                        itemBuilder: (_, i) {
                          final pageNum = i + 1;
                          final isSelected = _selectedPages.contains(pageNum);
                          return _PageThumbnail(
                            document: _document,
                            pageIndex: i,
                            pageNum: pageNum,
                            isSelected: isSelected,
                            onTap: () => _togglePage(pageNum),
                          );
                        },
                      ),
                    ),

                    // Bottom bar
                    if (_selectedPages.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: AppColors.surface,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _deleteSelectedPages,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error),
                          icon: const Icon(Icons.delete),
                          label: Text(isId
                              ? 'Hapus ${_selectedPages.length} Halaman'
                              : 'Delete ${_selectedPages.length} Pages'),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _PageThumbnail extends StatefulWidget {
  final PdfDocument document;
  final int pageIndex;
  final int pageNum;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageThumbnail({
    required this.document,
    required this.pageIndex,
    required this.pageNum,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PageThumbnail> createState() => _PageThumbnailState();
}

class _PageThumbnailState extends State<_PageThumbnail> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _renderThumbnail();
  }

  Future<void> _renderThumbnail() async {
    try {
      final page = widget.document.pages[widget.pageIndex];
      final image = await page.render(width: 200, height: 280);
      if (mounted && image != null) {
        setState(() => _thumbnail = image.pixels);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Thumbnail
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.error
                    : AppColors.divider,
                width: widget.isSelected ? 3 : 1,
              ),
              color: AppColors.background,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _thumbnail != null
                  ? Image.memory(_thumbnail!, fit: BoxFit.cover,
                      width: double.infinity, height: double.infinity)
                  : const Center(
                      child: Icon(Icons.picture_as_pdf,
                          color: AppColors.textSecondary, size: 32)),
            ),
          ),

          // Overlay merah kalau dipilih
          if (widget.isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: AppColors.error.withOpacity(0.3),
              ),
              child: const Center(
                child: Icon(Icons.delete, color: Colors.white, size: 36),
              ),
            ),

          // Nomor halaman
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.pageNum}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
