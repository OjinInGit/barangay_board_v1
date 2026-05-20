import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_strings.dart';
import '../../services/firestore_service.dart';
import '../../utils/auth_error_message.dart';
import '../../utils/form_validators.dart';
import '../../utils/password_rules.dart';
import '../../widgets/auth_branded_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  final _retype = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  static final _nameInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s\-\.]')),
  ];

  FirestoreService get _fs =>
      FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text != _retype.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.errPasswordMismatch)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _fs.registerResident(
        email: _email.text.trim(),
        username: _user.text.trim(),
        password: _pass.text,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        middleInitial: _mi.text.trim(),
        suffix: _suffix.text.trim(),
      );
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.registrationSuccess)),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(s, e))),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'name-taken' => s.errNameTaken,
        'username-taken' => s.errUsernameTaken,
        _ => '${s.errRegistrationServer} (${e.code})',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.genericError)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _mi, _suffix, _user, _email, _pass, _retype]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AuthBrandedScaffold(
      title: s.register,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.register,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _first,
                textCapitalization: TextCapitalization.words,
                inputFormatters: _nameInputFormatters,
                decoration: InputDecoration(
                  labelText: s.firstName,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (v) => validateNameLetters(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last,
                textCapitalization: TextCapitalization.words,
                inputFormatters: _nameInputFormatters,
                decoration: InputDecoration(
                  labelText: s.lastName,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (v) => validateNameLetters(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mi,
                decoration: InputDecoration(
                  labelText: s.middleInitial,
                  prefixIcon: const Icon(Icons.abc),
                  helperText: s.middleInitialHint,
                ),
                maxLength: 1,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                ],
                textCapitalization: TextCapitalization.characters,
                onChanged: (v) {
                  if (v.isEmpty) return;
                  final letter = v[v.length - 1].toUpperCase();
                  if (_mi.text != letter) {
                    _mi.value = TextEditingValue(
                      text: letter,
                      selection: TextSelection.collapsed(offset: letter.length),
                    );
                  }
                },
                validator: (v) => validateMiddleInitial(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _suffix,
                textCapitalization: TextCapitalization.words,
                inputFormatters: _nameInputFormatters,
                decoration: InputDecoration(
                  labelText: s.suffix,
                  prefixIcon: const Icon(Icons.short_text),
                ),
                validator: (v) => validateSuffix(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _user,
                decoration: InputDecoration(
                  labelText: s.username,
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
                validator: (v) => validateUsername(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: s.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  helperText: s.emailFormatHint,
                ),
                validator: (v) => validateEmailFormat(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: s.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  helperText: s.passwordRequirementsHint,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                validator: (v) => validateRegistrationPassword(s, v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _retype,
                obscureText: _obscure2,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  labelText: s.retypePassword,
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return s.fieldRequired;
                  if (v != _pass.text) return s.errPasswordMismatch;
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
    );
  }
}
