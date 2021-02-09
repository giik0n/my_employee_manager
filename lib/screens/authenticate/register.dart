import 'package:flutter/material.dart';
import 'package:my_employee_manager/services/auth.dart';
import 'package:my_employee_manager/shared/constants.dart';
import 'package:my_employee_manager/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool loading = false;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String email = "";
  String password = "";
  String error = "";
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            //backgroundColor: Colors.grey[200],
            appBar: AppBar(
              //backgroundColor: Colors.green,
              elevation: 0.0,
              title: Text('Sign up'),
              actions: <Widget>[
                FlatButton.icon(
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: Icon(
                    Icons.person,
                    //color: Colors.green[50],
                  ),
                  label: Text(
                    "Sign In",
                    //style: TextStyle(color: Colors.green[50]),
                  ),
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                          "assets/images/icons8-view-carousel-100.png"),
                      Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            decoration: new InputDecoration(
                              hintText: 'Email',
                              icon: const Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: const Icon(Icons.person),
                              ),
                            ),
                            validator: (val) =>
                                val.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            decoration: new InputDecoration(
                              hintText: 'Password',
                              icon: const Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: const Icon(Icons.lock),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _toggle();
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (val) => val.length < 6
                                ? 'Enter a password 6+ chars long'
                                : null,
                            obscureText: _obscureText,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                            onFieldSubmitted: (str) async {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                dynamic result = await _authService
                                    .signInWithEmailAndPassword(
                                        email.trim(), password);
                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error = "Cant sign in";
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      RaisedButton(
                        //color: Colors.white,
                        child: Text(
                          'Register',
                          //style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            dynamic result =
                                await _authService.registerWithEmailAndPassword(
                                    email.trim(), password);
                            if (result == null) {
                              loading = false;
                              setState(() {
                                error = "Please supply a valid email";
                              });
                            }
                          }
                        },
                      ),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
