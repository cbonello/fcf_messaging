import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/blocs/signin/signin_bloc.dart';
import 'package:fcf_messaging/src/screens/widgets/form_fields.dart';
import 'package:fcf_messaging/src/screens/widgets/horizontal_line.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigninForm extends StatefulWidget {
  @override
  _SigninFormState createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm>
    with AutomaticKeepAliveClientMixin<SigninForm> {
  TextEditingController _emailController, _passwordController;
  FocusNode _emailFocus, _passwordFocus;
  SignInBloc _signinBloc;
  final Flushbar<Object> _signingInFlushbar = FlushbarHelper.createLoading(
    message: 'Signing in...',
    linearProgressIndicator: const LinearProgressIndicator(),
  );
  // bool _showAppleSignIn = false;

  bool get isPopulated =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  bool isSignInButtonEnabled(SignInState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _signinBloc = context.bloc<SignInBloc>();
    _emailController = TextEditingController();
    _emailController.addListener(_onEmailChanged);
    _passwordController = TextEditingController();
    _passwordController.addListener(_onPasswordChanged);
    _emailFocus = FocusNode(debugLabel: 'Email');
    _passwordFocus = FocusNode(debugLabel: 'Password');
    // _userAppleSignIn();
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _emailFocus.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SignInBloc, SignInState>(
      listener: (BuildContext context, SignInState state) {
        if (state.exceptionRaised != null) {
          FlushbarHelper.createError(
            title: 'Sign in failure',
            message: state.exceptionRaised.message,
          )..show(context);
        } else if (state.isSubmitting) {
          _signingInFlushbar.show(context);
        } else if (state.isSuccess) {
          assert(state.user != null);
          context.bloc<AuthenticationBloc>().add(SignedIn(user: state.user));
          _signingInFlushbar.dismiss();
        }
      },
      child: BlocBuilder<SignInBloc, SignInState>(
        builder: (BuildContext context, SignInState state) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  child: Column(
                    children: <Widget>[
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
                        validator: (_) =>
                            _emailController.text.isNotEmpty && !state.isEmailValid
                                ? 'Enter a valid email address'
                                : null,
                      ),
                      const SizedBox(height: 10.0),
                      AppPassworFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                      ),
                      const SizedBox(height: 20.0),
                      RaisedButton(
                        color: Colors.green,
                        onPressed: isSignInButtonEnabled(state) ? _onFormSubmitted : null,
                        child: const Text(
                          'Sign In',
                          // style: isSignInButtonEnabled(state)
                          //     ? AppTheme.buttonEnabledTextStyle
                          //     : AppTheme.buttonDisabledTextStyle,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: const <Widget>[
                              Expanded(child: HorizontalLine()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('OR'),
                              ),
                              Expanded(child: HorizontalLine()),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: GoogleSignInButton(
                          borderRadius: 6.0,
                          darkMode: Theme.of(context).brightness == Brightness.dark,
                          onPressed: () {
                            context.bloc<SignInBloc>().add(SignInWithGooglePressed());
                          },
                        ),
                      ),
                      // if (_showAppleSignIn)
                      //   Container(
                      //     width: double.infinity,
                      //     child: AppleSignInButton(
                      //       borderRadius: 6.0,
                      //       onPressed: () {
                      //         BlocProvider.of<SigninBloc>(context).add(
                      //           SignInWithApplePressed(),
                      //         );
                      //       },
                      //     ),
                      //   ),
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

  // Future<void> _userAppleSignIn() async {
  //   if (Platform.isIOS) {
  //     final IosDeviceInfo deviceInfo = await DeviceInfoPlugin().iosInfo;
  //     final String version = deviceInfo.systemVersion;
  //     if (double.parse(version) >= 13) {
  //       setState(() => _showAppleSignIn = true);
  //     }
  //   }
  // }

  void _onEmailChanged() {
    _signinBloc.add(
      EmailChanged(email: _emailController.text.trim()),
    );
    setState(() {});
  }

  void _onPasswordChanged() {
    _signinBloc.add(
      PasswordChanged(password: _passwordController.text.trim()),
    );
    setState(() {});
  }

  void _onFormSubmitted() {
    _signinBloc.add(
      SignInWithEmailAndPasswordPressed(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
