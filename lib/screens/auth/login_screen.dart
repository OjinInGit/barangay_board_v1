import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import '../../services/messaging_service.dart';
import '../../utils/auth_error_message.dart';
import '../../widgets/auth_branded_scaffold.dart';
import '../admin/admin_home_screen.dart';
import '../resident/resident_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  FirestoreService get _fs =>
      FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);

  Future<void> _submit() async {
    final s0 = AppStrings.of(context);
    if (_passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s0.emptyPassword)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final input = _userCtrl.text.trim();
      final email = input.contains('@')
          ? input
          : await _fs.emailForUsername(input);
      if (!mounted) return;
      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s0.invalidCredentials)),
        );
        return;
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final profile = await _fs.profileForUid(uid);
      if (!mounted) return;
      if (profile == null) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s0.genericError)),
        );
        return;
      }
      if (!profile.active) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s0.accountDeactivated)),
        );
        return;
      }
      if (profile.role == UserRole.resident) {
        await MessagingService.instance.subscribeResidentTopics();
        final token = await MessagingService.instance.getToken();
        if (token != null) await _fs.updateFcmToken(token);
      }
      if (!mounted) return;
      if (profile.role == UserRole.admin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AdminHomeScreen()),
          (r) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => ResidentHomeScreen(username: profile.username),
          ),
          (r) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(AppStrings.of(context), e))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s0.genericError)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AuthBrandedScaffold(
      title: s.login,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.login, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _userCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: s.username),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: s.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
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
                    : Text(s.login),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: Text(s.noAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
