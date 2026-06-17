import 'package:flutter/material.dart';

import '../models/agenda.dart';
import '../services/agenda_service.dart';
import '../widgets/agenda_states.dart';

class AgendaDetailSheet extends StatefulWidget {
  const AgendaDetailSheet({
    required this.agendaService, 
    required this.agenda, 
    required this.onChanged, 
    super.key,
  });

  final AgendaService agendaService;
  final Agenda agenda;
  final Future<void> Function() onChanged;

  @override
  State<AgendaDetailSheet> createState() => _AgendaDetailSheetState();
}

class _AgendaDetailSheetState extends State<AgendaDetailSheet> {
  late Agenda _agenda;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = true;
  bool _submittingLike = false;
  bool _submittingComment = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _agenda = widget.agenda;
    _loadDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await widget.agendaService.fetchAgenda(_agenda.id);
      final comments = await widget.agendaService.fetchComments(_agenda.id);
      if (!mounted) return;
      setState(() {
        _agenda = detail.copyWith(daftarKomentar: comments);
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _submittingLike = true);
    try {
      await widget.agendaService.toggleLike(_agenda.id);
      await _loadDetail();
      await widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingLike = false);
      }
    }
  }

  Future<void> _sendComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() => _submittingComment = true);
    try {
      final updated = await widget.agendaService.comment(_agenda.id, message);
      if (!mounted) return;
      setState(() {
        _agenda = updated;
        _commentController.clear();
      });
      // Amankan pemanggilan loadDetail setelah kirim komentar agar jumlah list ikut terupdate rapi
      await _loadDetail();
      await widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFDF2F2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC41C1C)),
                  ),
                )
              : SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...<Widget>[
                          const SizedBox(height: 16),
                          InlineMessage(
                            message: _errorMessage!,
                            onRetry: _loadDetail,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _agenda.imageUrl != null
                              ? Image.network(
                                  _agenda.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFF9CA3AF),
                                    size: 60,
                                  ),
                                )
                              : const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 60,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _agenda.kategori,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC41C1C),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _agenda.judul,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7F1D1D),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),

                        // --- FIELD INPUT MENULIS KOMENTAR ---
                        Text(
                          'Komentar (${_agenda.daftarKomentar.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tulis komentar Anda di sini...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFD1D5DB),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC41C1C),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: _submittingComment ? null : _sendComment,
                            child: _submittingComment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Kirim Komentar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),

                        // --- TEKS DESKRIPSI UTAMA ---
                        const Text(
                          'Deskripsi Agenda:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _agenda.deskripsi.isNotEmpty ? _agenda.deskripsi : 'Tidak ada deskripsi.',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),

                        // --- TANGGAL AGENDA ---
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF8A4A4A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _agenda.formatTanggal,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A4A4A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // --- TOMBOL SUKA DAN JUMLAH KOMENTAR ---
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _submittingLike ? null : _toggleLike,
                                icon: _submittingLike
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.favorite_outline),
                                label: Text('${_agenda.likes} Suka'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC41C1C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.comment_outlined,
                                      size: 16,
                                      color: Color(0xFF8A4A4A),
                                    ),
                                    const SizedBox(width: 6),
                                    
                                    // --- PERBAIKAN DI ATASI DI SINI ---
                                    Text(
                                      '${_agenda.daftarKomentar.length} Komentar',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),

                        // --- DAFTAR LIST KOMENTAR USER ---
                        if (_agenda.daftarKomentar.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _agenda.daftarKomentar.length,
                            itemBuilder: (context, index) {
                              final komentar = _agenda.daftarKomentar[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            komentar.nama,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          Text(
                                            komentar.formatTanggal,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        komentar.isi,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4B5563),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}