import 'package:calculator/widgets/select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class CalcButton {
  final String buttonLabel;
  final String inDisplay;
  final String expression;

  const CalcButton(this.buttonLabel, {String? inDisplay, String? expression})
      : inDisplay = inDisplay ?? buttonLabel,
        expression = expression ?? buttonLabel;

  const CalcButton.function(buttonLabel, {String? expression})
      : this(buttonLabel, inDisplay: " $buttonLabel ", expression: expression);

  const CalcButton.withX(buttonLabel, expression)
      : this(buttonLabel, inDisplay: expression, expression: expression);
}

class _CalculatorState extends State<Calculator> {
  static const List<CalcButton> normalButtons = [
    CalcButton("C"),
    CalcButton("←"),
    CalcButton("%", expression: "/(100)"),
    CalcButton("/"),
    CalcButton("7"),
    CalcButton("8"),
    CalcButton("9"),
    CalcButton("*"),
    CalcButton("4"),
    CalcButton("5"),
    CalcButton("6"),
    CalcButton("-"),
    CalcButton("1"),
    CalcButton("2"),
    CalcButton("3"),
    CalcButton("+"),
    CalcButton("^"),
    CalcButton("0"),
    CalcButton("."),
    CalcButton("="),
  ];
  static const List<CalcButton> extraButtons = [
    CalcButton.function("sin"),
    CalcButton.function("cos"),
    CalcButton.function("tan"),
    CalcButton.function("log"),
    CalcButton.function("ln"),
    CalcButton.function("mod", expression: "%"),
    CalcButton("|x|", inDisplay: " abs ", expression: "abs"),
    CalcButton.withX("1/x", "1/"),
    CalcButton("eˣ", inDisplay: "e^", expression: "e"),
    CalcButton.withX("x²", "^(2)"),
    CalcButton.withX("xʸ", "^"),
    CalcButton("²√x", inDisplay: "√", expression: "sqrt"),
    CalcButton("ⁿ√x", inDisplay: "√", expression: "nrt"),
    CalcButton("("),
    CalcButton(")"),
    CalcButton(","),
  ];
  final Parser parser = Parser();
  final ContextModel cm = ContextModel();
  final List<List<CalcButton>> history = [
    [const CalcButton("0")]
  ];
  int historyIndex = -1;
  List<CalcButton> expression = [];

  String result = "";
  bool unlockTried = false;
  bool portrait = true;
  List<CalcButton> buttons = normalButtons;

  String exprListToString(List<CalcButton> exp) {
    return exp.isEmpty ? "0" : exp.map((button) => button.inDisplay).join();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    buttons = portrait ? normalButtons : extraButtons + normalButtons;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(exprListToString(expression),
                style: const TextStyle(color: Colors.white, fontSize: 34)),
            Text(result,
                style: const TextStyle(color: Colors.white70, fontSize: 24)),
            _iconRow(),
            Expanded(
              child: GridView.count(
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: portrait ? 4 : 3,
                padding: EdgeInsets.zero,
                scrollDirection: portrait ? Axis.vertical : Axis.horizontal,
                children: List.generate(buttons.length,
                    (index) => _button(buttons.elementAt(index))),
              ),
            ),
          ]),
        ),
      );

  Widget _iconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: "Settings",
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.of(context).pushNamed("settings"),
        ),
        IconButton(
          tooltip: "Switch Orientation",
          icon: const Icon(Icons.calculate),
          onPressed: () {
            SystemChrome.setPreferredOrientations(portrait
                ? [
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight
                  ]
                : [
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown
                  ]);
            Future.delayed(
                const Duration(seconds: 5),
                () => SystemChrome.setPreferredOrientations(
                    DeviceOrientation.values));
          },
        ),
        IconButton(
          tooltip: "Undo",
          icon: const Icon(Icons.undo),
          onPressed: () => setState(() {
            if (history.isNotEmpty && historyIndex > 0) {
              historyIndex--;
              expression = history[historyIndex];
              _calculateResult();
            } else {
              result = "Nothing to undo";
            }
          }),
        ),
        IconButton(
          tooltip: "Redo",
          icon: const Icon(Icons.redo),
          onPressed: () => setState(() {
            if (history.isNotEmpty && historyIndex < history.length - 1) {
              historyIndex++;
              expression = history[historyIndex];
              _calculateResult();
            } else {
              result = "Nothing to redo";
            }
          }),
        ),
        IconButton(
          tooltip: "History",
          icon: const Icon(Icons.history),
          onPressed: () => selectDialog(
              context,
              history,
              "Expression",
              exprListToString,
              (List<CalcButton> exp) => setState(() {
                    expression = exp;
                    historyIndex = history.indexOf(exp);
                    _calculateResult();
                  })),
        ),
        IconButton(
          tooltip: "Delete",
          icon: const Icon(Icons.backspace),
          onPressed: () => _onPressed(const CalcButton("←")),
        )
      ],
    );
  }

  Widget _button(CalcButton button) {
    const radius = BorderRadius.all(Radius.circular(20));
    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: radius,
      color: extraButtons.contains(button)
          ? Colors.orange[600]
          : Colors.green[600],
      child: InkWell(
        borderRadius: radius,
        onTap: () => _onPressed(button),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              button.buttonLabel,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }

  void _calculateResult() {
    if (expression.isEmpty) {
      result = "";
      return;
    }
    try {
      Expression exp =
          parser.parse(expression.map((button) => button.expression).join());
      result = exp.evaluate(EvaluationType.REAL, cm).toString();
    } catch (error) {
      result = "Error: $error";
    }
  }

  void _onPressed(CalcButton button) {
    setState(() {
      switch (button.buttonLabel) {
        case "←":
          if (expression.isNotEmpty) expression.removeLast();
          break;
        case "C":
          expression.clear();
          break;
        case "=":
          history.add(expression.toList());
          _calculateResult();
          expression = [CalcButton(result)];
          break;
        default:
          expression.add(button);
      }
      _calculateResult();
    });
  }
}
