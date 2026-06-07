import 'package:flutter/material.dart';
import '../models/aspirasi.dart';
import '../services/aspirasi_service.dart';

class AspirasiDetailPage extends StatefulWidget {
  const AspirasiDetailPage({
    super.key,
    required this.aspirasiId,
  });

  final String aspirasiId;

  static const String routeName = '/aspirasi-detail';

  @override
  State<AspirasiDetailPage> createState() => _AspirasiDetailPageState();
}

class _AspirasiDetailPageState extends State<AspirasiDetailPage> {
  final AspirasiService _service = AspirasiService();
  final TextEditingController _commentController = TextEditingController();

  Aspirasi? _aspirasi;
  List<AspirasiComment> _comments = [];
  bool _isLoading = true;
  bool _isVoting = false;
  bool _isCommenting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.fetchAspirasiDetail(widget.aspirasiId),
        _service.fetchComments(widget.aspirasiId),
      ]);

      if (mounted) {
        setState(() {
          _aspirasi = results[0] as Aspirasi;
          _comments = results[1] as List<AspirasiComment>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleVote() async {
    if (_aspirasi == null || _isVoting) return;

    setState(() => _isVoting = true);

    try {
      final voted = await _service.toggleVote(widget.aspirasiId);

      if (mounted) {
        setState(() {
          _aspirasi = _aspirasi!.copyWith(
            hasVoted: voted,
            votes: voted ? _aspirasi!.votes + 1 : _aspirasi!.votes - 1,
          );
          _isVoting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVoting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memberikan vote: $e'),
            backgroundColor: const Color(0xFFC41C1C),
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isCommenting) return;

    setState(() => _isCommenting = true);

    try {
      await _service.postComment(widget.aspirasiId, text);
      _commentController.clear();

      // Reload comments
      final comments = await _service.fetchComments(widget.aspirasiId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isCommenting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCommenting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim komentar: $e'),
            backgroundColor: const Color(0xFFC41C1C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
      appBar: AppBar(
        title: const Text('Detail Aspirasi'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB91C1C),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFC41C1C),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB91C1C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_aspirasi == null) {
      return const Center(child: Text('Aspirasi tidak ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFB91C1C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildAspirasiCard(),
            _buildCommentsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAspirasiCard() {
    final aspirasi = _aspirasi!;
    final hasVoted = aspirasi.hasVoted ?? false;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1ADCDCDC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  aspirasi.judul,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7F1D1D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(aspirasi.status),
            ],
          ),
          const SizedBox(height: 12),

          // Meta info
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetaChip(Icons.folder_outlined, aspirasi.kategori),
              _buildMetaChip(Icons.person_outline, aspirasi.displayAuthor),
              _buildMetaChip(Icons.calendar_today_outlined, aspirasi.formatTanggal),
              _buildMetaChip(Icons.thumb_up_outlined, '${aspirasi.votes} Votes'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // Deskripsi
          const Text(
            'Deskripsi Aspirasi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              aspirasi.deskripsi,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ),

          // Tujuan/Manfaat
          if (aspirasi.tujuanManfaat.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Tujuan/Manfaat',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                aspirasi.tujuanManfaat,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Lampiran
          if (aspirasi.lampiran != null && aspirasi.lampiran!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFDFCFC),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lampiran Tersedia',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lampiran: ${aspirasi.lampiran}'),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat File',
                      style: TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Tanggapan BEM
          if (aspirasi.bemResponse != null && aspirasi.bemResponse!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFF10B981),
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 18,
                        color: Color(0xFF065F46),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tanggapan BEM:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aspirasi.bemResponse!,
                    style: const TextStyle(
                      color: Color(0xFF064E3B),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Vote Button
          Align(
            alignment: Alignment.centerRight,
            child: _isVoting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFB91C1C),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _toggleVote,
                    icon: Icon(
                      hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 18,
                    ),
                    label: Text('Dukung (${aspirasi.votes})'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: hasVoted
                          ? const Color(0xFFFEF2F2)
                          : Colors.white,
                      foregroundColor: hasVoted
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF6B7280),
                      side: BorderSide(
                        color: hasVoted
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFD1D5DB),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1ADCDCDC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar (${_comments.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 20),

          // Comment Form
          _buildCommentForm(),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // Comments List
          if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada komentar.\nJadilah yang pertama memberikan tanggapan!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (_, __) => const Divider(
                color: Color(0xFFE5E7EB),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tulis tanggapan atau komentar Anda...',
            hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB91C1C)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: _isCommenting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFB91C1C),
                  ),
                )
              : ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Kirim Komentar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(AspirasiComment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              comment.userName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                fontSize: 14,
              ),
            ),
            Text(
              comment.timeAgo,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          comment.text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFB91C1C),
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
