import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/repos.dart';
import '../l10n/app_strings.dart';
import '../utils/auth_error_message.dart';
import '../utils/password_rules.dart';
import '../utils/snacks.dart';
import '../widgets/auth_header.dart';
import '../widgets/branded_auth_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.repos});

  final AppRepos repos;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _mi = TextEditingController();
  final _suffix = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscure2 = true;

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text != _confirm.text) {
      showSnack(context, s.errPasswordMismatch);
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.repos.users.registerResident(
        email: _email.text,
        password: _pass.text,
        username: _user.text,
        firstName: _first.text,
        lastName: _last.text,
        middleInitial: _mi.text,
        suffix: _suffix.text,
      );
      await widget.repos.auth.signOut();
      if (!mounted) return;
      showSnack(context, 'Registration successful. Please log in.');
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showSnack(context, authErrorMessage(s, e));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showSnack(
        context,
        e.code == 'permission-denied' ? s.errPermissionDenied : s.genericError,
      );
    } catch (_) {
      if (!mounted) return;
      showSnack(context, s.genericError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _mi.dispose();
    _suffix.dispose();
    _user.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.register)),
      body: BrandedAuthBackground(
        child: AbsorbPointer(
          absorbing: _loading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _first,
                    decoration: InputDecoration(labelText: s.firstName),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _last,
                    decoration: InputDecoration(labelText: s.lastName),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _mi,
                    maxLength: 1,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(labelText: s.middleInitial),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _suffix,
                    decoration: InputDecoration(labelText: s.suffix),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _user,
                    decoration: InputDecoration(labelText: s.username),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: s.email),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      labelText: s.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      final p = describePasswordProblem(v ?? '');
                      if (p != null) return s.passwordProblemMessage(p);
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure2,
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      labelText: s.retypePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? s.fieldRequired : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(s.register),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: Text(s.haveAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
