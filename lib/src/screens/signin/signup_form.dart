import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/blocs/signup/signup_bloc.dart';
import 'package:fcf_messaging/src/utils/validators.dart';
import 'package:fcf_messaging/src/widgets/form_fields.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm>
    with AutomaticKeepAliveClientMixin<SignupForm> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  FocusNode _nameFocus, _emailFocus, _passwordFocus;
  bool _agreedToTOSAndPolicy;
  SignUpBloc _signupBloc;
  final Flushbar<Object> _signingUpFlushbar = FlushbarHelper.createLoading(
    message: 'Signing up...',
    linearProgressIndicator: const LinearProgressIndicator(),
  );

  bool get isPopulated =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty &&
      _agreedToTOSAndPolicy;

  bool isSignUpButtonEnabled(SignUpState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _agreedToTOSAndPolicy = false;
    _signupBloc = context.bloc<SignUpBloc>();
    _nameController = TextEditingController();
    _nameController.addListener(_onNameChanged);
    _emailController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
    _passwordController = TextEditingController();
    _passwordController.addListener(_onPasswordChanged);
    _nameFocus = FocusNode(debugLabel: 'Name');
    _emailFocus = FocusNode(debugLabel: 'Email');
    _passwordFocus = FocusNode(debugLabel: 'Password');
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (BuildContext context, SignUpState state) {
        if (state.isFailure) {
          FlushbarHelper.createError(
            title: 'Sign up failure',
            message: state.exceptionRaised.message,
          )..show(context);
          // Scaffold.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(
          //     SnackBar(
          //       content: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: <Widget>[
          //           const Icon(Icons.error),
          //           Text('Sign up failure: ${state.exceptionRaised.message}'),
          //         ],
          //       ),
          //       backgroundColor: AppTheme.snackBarError.backgroundColor,
          //     ),
          //   );
        } else if (state.isSubmitting) {
          _signingUpFlushbar.show(context);
          // Scaffold.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(
          //     SnackBar(
          //       content: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: const <Widget>[
          //           CircularProgressIndicator(),
          //           Text('Signin up...'),
          //         ],
          //       ),
          //     ),
          //   );
        } else if (state.isSuccess) {
          context.bloc<AuthenticationBloc>().add(SignedIn(user: state.user));
          _signingUpFlushbar.dismiss();
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (BuildContext context, SignUpState state) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      AppTextFormField(
                        labelText: 'Name',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        focusNode: _nameFocus,
                        textCapitalization: TextCapitalization.sentences,
                        onFieldSubmitted: (_) {
                          fieldFocusChangeCallback(
                            context,
                            _nameFocus,
                            _emailFocus,
                          );
                        },
                      ),
                      const SizedBox(height: 10.0),
                      AppTextFormField(
                        labelText: 'Email',
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocus,
                        onFieldSubmitted: (_) {
                          fieldFocusChangeCallback(
                            context,
                            _emailFocus,
                            _passwordFocus,
                          );
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (_) {
                          if (_emailController.text.isNotEmpty) {
                            if (state.isEmailValid == false) {
                              return 'Enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      AppPassworFormField(
                        controller: _passwordController,
                        validator: (_) {
                          if (_passwordController.text.isNotEmpty) {
                            if (!isValidPasswordLength(_passwordController.text)) {
                              return 'Password is too short ($MIN_PASSWORD_LENGTH characters minimum)';
                            }
                            if (!isValidPasswordStrength(_passwordController.text)) {
                              return 'Password is too weak';
                            }
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            /// checkColor: ACCENT_COLOR,
                            value: _agreedToTOSAndPolicy,
                            onChanged: _onTOSChanged,
                          ),
                          // Expanded(Container()) to prevent text overflow.
                          Expanded(
                            child: Container(
                              child: GestureDetector(
                                onTap: () => _onTOSChanged(!_agreedToTOSAndPolicy),
                                child: const Text(
                                  'I agree to the Terms of Services and Privacy Policy',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed:
                              isSignUpButtonEnabled(state) ? _onFormSubmitted : null,
                          child: const Text(
                            'Sign Up',
                            // style: isSignUpButtonEnabled(state)
                            //     ? AppTheme.buttonEnabledTextStyle
                            //     : AppTheme.buttonDisabledTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onNameChanged() {
    _signupBloc.add(
      NameChanged(name: _nameController.text.trim()),
    );
    setState(() {});
  }

  void _onEmailChanged() {
    _signupBloc.add(
      EmailChanged(email: _emailController.text.trim()),
    );
    setState(() {});
  }

  void _onPasswordChanged() {
    _signupBloc.add(
      PasswordChanged(password: _passwordController.text.trim()),
    );
    setState(() {});
  }

  void _onTOSChanged(bool newValue) {
    setState(() {
      _agreedToTOSAndPolicy = newValue;
    });
    setState(() {});
  }

  void _onFormSubmitted() {
    _signupBloc.add(
      Submitted(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        tosPrivacyAccepted: _agreedToTOSAndPolicy,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NameWidget extends StatefulWidget {
  const NameWidget({
    Key key,
    @required this.firstnameController,
    @required this.lastnameController,
    @required this.nextFocusField,
  }) : super(key: key);

  final TextEditingController firstnameController, lastnameController;
  final FocusNode nextFocusField;

  @override
  _NameWidgetState createState() => _NameWidgetState();
}

class _NameWidgetState extends State<NameWidget> {
  FocusNode _firstnameFocus, _lastnameFocus;

  @override
  void initState() {
    _firstnameFocus = FocusNode(debugLabel: 'First Name');
    _lastnameFocus = FocusNode(debugLabel: 'Last Name');
    super.initState();
  }

  @override
  void dispose() {
    _lastnameFocus.dispose();
    _firstnameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (MediaQuery.of(context).size.width >= 600) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: AppTextFormField(
                  labelText: 'First name',
                  controller: widget.firstnameController,
                  textInputAction: TextInputAction.next,
                  focusNode: _firstnameFocus,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (_) {
                    fieldFocusChangeCallback(context, _firstnameFocus, _lastnameFocus);
                  },
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: AppTextFormField(
                  labelText: 'Last name',
                  controller: widget.lastnameController,
                  textInputAction: TextInputAction.next,
                  focusNode: _lastnameFocus,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (_) {
                    fieldFocusChangeCallback(
                      context,
                      _lastnameFocus,
                      widget.nextFocusField,
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Column(
          children: <Widget>[
            AppTextFormField(
              labelText: 'First name',
              controller: widget.firstnameController,
              textInputAction: TextInputAction.next,
              focusNode: _firstnameFocus,
              onFieldSubmitted: (_) {
                fieldFocusChangeCallback(context, _firstnameFocus, _lastnameFocus);
              },
            ),
            const SizedBox(height: 10.0),
            AppTextFormField(
              labelText: 'Last name',
              controller: widget.lastnameController,
              textInputAction: TextInputAction.next,
              focusNode: _lastnameFocus,
              onFieldSubmitted: (_) {
                fieldFocusChangeCallback(context, _lastnameFocus, widget.nextFocusField);
              },
            ),
          ],
        );
      },
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({Key key, this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: onPressed,
      child: const Text('Register'),
    );
  }
}
