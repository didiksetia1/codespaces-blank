import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/auth_service_sanctum.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedFakultas;
  String? _selectedProdi;

  final SanctumAuthService _sanctum =
      SanctumAuthService(SanctumAuthService.apiBaseUrl);

  // Data fakultas & prodi sesuai web
  final List<String> _fakultasList = [
    'Fakultas Teknik Telekomunikasi dan Elektro (FTTE)',
    'Fakultas Informatika (FIF)',
    'Fakultas Rekayasa Industri dan Desain (FRID)',
  ];

  final Map<String, List<String>> _prodiMap = {
    'Fakultas Teknik Telekomunikasi dan Elektro (FTTE)': [
      'D3 Teknik Telekomunikasi',
      'S1 Teknik Telekomunikasi',
      'S1 Teknik Elektro',
      'S1 Teknik Biomedis',
    ],
    'Fakultas Informatika (FIF)': [
      'S1 Teknik Informatika',
      'S1 Software Engineering (Rekayasa Perangkat Lunak)',
      'S1 Sistem Informasi',
      'S1 Sains Data',
    ],
    'Fakultas Rekayasa Industri dan Desain (FRID)': [
      'S1 Teknik Industri',
      'S1 Teknik Logistik',
      'S1 Desain Komunikasi Visual (DKV)',
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFakultas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih Fakultas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedProdi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih Program Studi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _sanctum.register(
        nim: _nimController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        faculty: _selectedFakultas,
        program: _selectedProdi,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi gagal. Periksa data atau NIM sudah terdaftar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFDFD), Color(0xFFFFECEC)],
          ),
        ),
        child: Stack(
          children: [
            // Ambient circles (mirip web)
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDC2626).withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphism Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB91C1C).withOpacity(0.15),
                              blurRadius: 45,
                              offset: const Offset(0, 18),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFDC2626).withOpacity(0.12),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Title
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFFB91C1C),
                                    Color(0xFFEF4444),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Buat Akun',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Nama Lengkap
                              _buildInputField(
                                controller: _nameController,
                                hint: 'Nama Lengkap',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v!.isEmpty ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),

                              // NIM
                              _buildInputField(
                                controller: _nimController,
                                hint: 'NIM',
                                icon: Icons.badge_outlined,
                                validator: (v) =>
                                    v!.isEmpty ? 'NIM wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildInputField(
                                controller: _emailController,
                                hint: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v!.isEmpty) return 'Email wajib diisi';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Fakultas Dropdown
                              _buildDropdownField(
                                value: _selectedFakultas,
                                hint: 'Pilih Fakultas',
                                icon: Icons.school_outlined,
                                items: _fakultasList,
                                onChanged: (v) {
                                  setState(() {
                                    _selectedFakultas = v;
                                    _selectedProdi = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Prodi Dropdown
                              _buildDropdownField(
                                value: _selectedProdi,
                                hint: 'Pilih Program Studi',
                                icon: Icons.menu_book_outlined,
                                items: _selectedFakultas != null
                                    ? (_prodiMap[_selectedFakultas] ?? [])
                                    : [],
                                onChanged: (v) =>
                                    setState(() => _selectedProdi = v),
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _buildInputField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF7F1D1D)
                                        .withOpacity(0.5),
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v!.isEmpty) return 'Password wajib diisi';
                                  if (v.length < 8) return 'Password minimal 8 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildInputField(
                                controller: _confirmPasswordController,
                                hint: 'Konfirmasi Password',
                                icon: Icons.lock_outline,
                                obscure: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF7F1D1D)
                                        .withOpacity(0.5),
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword),
                                ),
                                validator: (v) {
                                  if (v!.isEmpty) return 'Konfirmasi password wajib diisi';
                                  if (v != _passwordController.text) return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: const Color(0xFFDC2626),
                                    disabledBackgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor:
                                        const Color(0xFFDC2626).withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Daftar Sekarang',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun? ',
                                    style: TextStyle(
                                      color: const Color(0xFF7F1D1D)
                                          .withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushReplacementNamed(
                                            LoginPage.routeName),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF7F1D1D),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF7F1D1D).withOpacity(0.45),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF7F1D1D).withOpacity(0.6),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.98),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFDC2626).withOpacity(0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFDC2626).withOpacity(0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF7F1D1D),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF7F1D1D).withOpacity(0.45),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF7F1D1D).withOpacity(0.6),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.98),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFDC2626).withOpacity(0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFDC2626).withOpacity(0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 2,
          ),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
    );
  }
}
