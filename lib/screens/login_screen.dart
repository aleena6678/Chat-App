import 'package:chat_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Login',
          style: TextStyle(fontSize: 40),
        ),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Hey, Chat App user! Login below:',
                      style: TextStyle(fontSize: 20,color: Colors.orange,fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10,),
                    TextField(
                      decoration: InputDecoration(hintText: 'email'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10,),
                    TextField(
                      decoration: InputDecoration(hintText: 'password'),
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20,),
                    Consumer<AuthProviderClass>(
                        builder: (context, provider, child) {
                          return Column(
                            children: [
                              ElevatedButton(
                                // only one press of the button trigger Firebase request
                                  onPressed: provider.isLoading ? null : () {
                                    provider.logIn(emailController.text.trim(), passwordController.text.trim());
                                  },
                                  child: provider.isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Login'),
                              ),
                              const SizedBox(height: 50,),
                              const Text(
                                'New to Chat App? Create an account below:',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),),
                              const SizedBox(height: 10,),
                              ElevatedButton(
                                onPressed: provider.isLoading ? null : () {
                                  provider.signUp(emailController.text.trim(), passwordController.text.trim());
                                }, child: provider.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Signup'),
                              ),
                              if (provider.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          );
                        }
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
