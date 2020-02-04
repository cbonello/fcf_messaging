import 'package:flutter/material.dart';

void fieldFocusChangeCallback(
  BuildContext context,
  FocusNode currentFocus,
  FocusNode nextFocus,
) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    Key key,
    String labelText,
    String helperText,
    String hintText,
    TextInputAction textInputAction,
    FocusNode focusNode,
    void Function(String) onFieldSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
    @required TextEditingController controller,
    String Function(String) validator,
  })  : _labelText = labelText,
        _helperText = helperText,
        _hintText = hintText,
        _textInputAction = textInputAction,
        _focusNode = focusNode,
        _onFieldSubmitted = onFieldSubmitted,
        _keyboardType = keyboardType,
        _textCapitalization = textCapitalization,
        _readOnly = readOnly,
        _controller = controller,
        _validator = validator,
        super(key: key);

  final String _labelText, _helperText, _hintText;
  final TextInputAction _textInputAction;
  final FocusNode _focusNode;
  final void Function(String) _onFieldSubmitted;
  final TextInputType _keyboardType;
  final TextCapitalization _textCapitalization;
  final bool _readOnly;
  final TextEditingController _controller;
  final String Function(String) _validator;

  @override
  _AppTextFormFieldState createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget._controller,
      decoration: InputDecoration(
        labelText: widget._labelText,
        helperText: widget._helperText,
        hintText: widget._hintText,
      ),
      textInputAction: widget._textInputAction,
      focusNode: widget._focusNode,
      onFieldSubmitted: widget._onFieldSubmitted,
      keyboardType: widget._keyboardType,
      textCapitalization: widget._textCapitalization,
      readOnly: widget._readOnly,
      autovalidate: true,
      autocorrect: false,
      validator: widget._validator,
    );
  }
}

class AppPassworFormField extends StatefulWidget {
  const AppPassworFormField({
    Key key,
    String labelText = 'Password',
    String helperText,
    String hintText,
    TextInputAction textInputAction,
    FocusNode focusNode,
    void Function(String) onFieldSubmitted,
    bool readOnly = false,
    @required TextEditingController controller,
    String Function(String) validator,
  })  : _labelText = labelText,
        _helperText = helperText,
        _hintText = hintText,
        _textInputAction = textInputAction,
        _focusNode = focusNode,
        _onFieldSubmitted = onFieldSubmitted,
        _readOnly = readOnly,
        _controller = controller,
        _validator = validator,
        super(key: key);

  final String _labelText, _helperText, _hintText;
  final bool _readOnly;
  final TextEditingController _controller;
  final TextInputAction _textInputAction;
  final FocusNode _focusNode;
  final void Function(String) _onFieldSubmitted;
  final String Function(String) _validator;

  @override
  _AppPassworFormFieldState createState() => _AppPassworFormFieldState();
}

class _AppPassworFormFieldState extends State<AppPassworFormField> {
  bool obscurePassword;

  @override
  void initState() {
    obscurePassword = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget._controller,
      decoration: InputDecoration(
        labelText: widget._labelText,
        helperText: widget._helperText,
        hintText: widget._hintText,
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
      ),
      textInputAction: widget._textInputAction,
      focusNode: widget._focusNode,
      onFieldSubmitted: widget._onFieldSubmitted,
      readOnly: widget._readOnly,
      obscureText: obscurePassword,
      autovalidate: true,
      autocorrect: false,
      validator: widget._validator,
    );
  }
}

class RaisedGradientButton extends StatelessWidget {
  const RaisedGradientButton({
    Key key,
    @required this.child,
    @required this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(6.0);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            ),
          ),
        ),
        Container(
          width: width,
          height: height,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            padding: EdgeInsets.zero,
            child: Center(child: child),
            onPressed: onPressed,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key key,
    this.size = 30.0,
    this.icon = Icons.clear,
    this.onPressed,
  }) : super(key: key);

  final double size;
  final Function onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: const Alignment(0.0, 0.0),
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]),
            ),
            Icon(
              icon,
              size: size * 0.6,
            )
          ],
        ),
      ),
    );
  }
}
