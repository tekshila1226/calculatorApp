import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String firstInput = ""; // Stores the first input number
  String operatorValue = ""; // Stores the operator (+, -, *, /)
  String secondInput = ""; // Stores the second input number
  bool isOperationComplete = true;

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // Output - top part
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Text(
                  "$firstInput$operatorValue$secondInput".isEmpty
                      ? "0"
                      : "$firstInput$operatorValue$secondInput",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Buttons - bottom part
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: screenDimensions.width / 4,
                      height: screenDimensions.width / 5,
                      child: createButton(value),
                    ),
                  )
                  .toList(),
            ),
          )
        ]),
      ),
    );
  }

  Widget createButton(value) {
    return Padding(
      padding: const EdgeInsets.all(3.0), // Padding around the button
      child: Material(
        color: fetchButtonColor(value), // Button background color
        clipBehavior: Clip.hardEdge, // Clip contents tightly to the shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(150), // Rounded corners
        ),
        elevation: 10, // Adds depth to simulate a shadow
        child: InkWell(
          onTap: () => handleButtonPress(value), // Handle button taps
          child: Container(
            alignment: Alignment.center, // Align text in the center
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Button colors
  Color fetchButtonColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? const Color.fromARGB(255, 160, 49, 108)
        : [
                Btn.per,
                Btn.multiply,
                Btn.add,
                Btn.subtract,
                Btn.divide,
                Btn.calculate,
              ].contains(value)
            ? const Color.fromARGB(255, 153, 110, 136)
            : const Color.fromARGB(221, 63, 62, 62);
  }

  bool isResultDisplayed = false;

  void appendInputValue(String value) {
    // Handling the result state (after "=" is pressed)
    if (isOperationComplete) {
      if (int.tryParse(value) != null || value == Btn.dot) {
        firstInput = value;
        operatorValue = "";
        secondInput = "";
        isOperationComplete = false;
        setState(() {});
        return;
      }
    }

    if (isResultDisplayed) {
      firstInput = "";
      operatorValue = "";
      secondInput = "";
      isResultDisplayed = false;
    }

    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operatorValue.isNotEmpty && secondInput.isNotEmpty) {
        performCalculation();
      }
      operatorValue = value;
    } else if (firstInput.isEmpty || operatorValue.isEmpty) {
      if (value == Btn.dot && firstInput.contains(Btn.dot)) return;
      if (value == Btn.dot && (firstInput.isEmpty || firstInput == Btn.n0)) {
        value = "0.";
      }
      firstInput += value;
    } else if (secondInput.isEmpty || operatorValue.isNotEmpty) {
      if (value == Btn.dot && secondInput.contains(Btn.dot)) return;
      if (value == Btn.dot && (secondInput.isEmpty || secondInput == Btn.n0)) {
        value = "0.";
      }
      secondInput += value;
    }

    setState(() {});
  }

  void handleButtonPress(String value) {
    if (value == Btn.del) {
      removeLastCharacter();
      return;
    }

    if (value == Btn.clr) {
      resetCalculator();
      return;
    }

    if (value == Btn.per) {
      convertPercentage();
      return;
    }

    if (value == Btn.calculate) {
      if (firstInput.isNotEmpty && operatorValue.isNotEmpty && secondInput.isNotEmpty) {
        performCalculation();
        isOperationComplete = true;
        setState(() {});
        return;
      }
    }

    if (isOperationComplete) {
      if (int.tryParse(value) != null || value == Btn.dot) {
        firstInput = value;
        operatorValue = "";
        secondInput = "";
        isOperationComplete = false;
        setState(() {});
        return;
      }
    }

    if (value == Btn.sqrt) {
      calculateSquareRoot();
      return;
    }

    appendInputValue(value);
  }

  void performCalculation() {
    if (firstInput.isEmpty || operatorValue.isEmpty || secondInput.isEmpty) return;

    final double num1 = double.parse(firstInput);
    final double num2 = double.parse(secondInput);

    String computationResult;

    switch (operatorValue) {
      case Btn.add:
        computationResult = (num1 + num2).toString();
        break;
      case Btn.subtract:
        computationResult = (num1 - num2).toString();
        break;
      case Btn.multiply:
        computationResult = (num1 * num2).toString();
        break;
      case Btn.divide:
        computationResult = num2 == 0 ? "Can't divide by 0" : (num1 / num2).toString();
        break;
      default:
        computationResult = "";
    }

    setState(() {
      if (computationResult == "Can't divide by 0") {
        firstInput = computationResult;
      } else {
        final parsedResult = double.parse(computationResult);
        firstInput = parsedResult % 1 == 0
            ? parsedResult.toInt().toString()
            : parsedResult.toStringAsPrecision(10);
      }

      operatorValue = "";
      secondInput = "";
    });
  }

  void removeLastCharacter() {
    if (secondInput.isNotEmpty) {
      secondInput = secondInput.substring(0, secondInput.length - 1);
    } else if (operatorValue.isNotEmpty) {
      operatorValue = "";
    } else if (firstInput.isNotEmpty) {
      firstInput = firstInput.substring(0, firstInput.length - 1);
    }

    setState(() {});
  }

  void resetCalculator() {
    setState(() {
      firstInput = "";
      operatorValue = "";
      secondInput = "";
    });
  }

  void convertPercentage() {
    if (firstInput.isNotEmpty && operatorValue.isNotEmpty && secondInput.isNotEmpty) {
      performCalculation();
    }

    if (operatorValue.isNotEmpty) {
      return;
    }

    final number = double.parse(firstInput);
    setState(() {
      firstInput = "${(number / 100)}";
      operatorValue = "";
      secondInput = "";
    });
  }

  void calculateSquareRoot() {
    if (firstInput.isEmpty || operatorValue.isNotEmpty) {
      return;
    }

    final double num1 = double.parse(firstInput);

    if (num1 < 0) {
      setState(() {
        firstInput = "Error";
      });
      return;
    }

    setState(() {
      firstInput = (sqrt(num1)).toStringAsFixed(10);
      firstInput = firstInput.contains('.')
          ? firstInput.replaceAll(RegExp(r'0*\$'), '').replaceAll(RegExp(r'\.\$'), '')
          : firstInput;

      operatorValue = "";
      secondInput = "";
    });
  }
}

class Btn {
  static const String n0 = "0";
  static const String n1 = "1";
  static const String n2 = "2";
  static const String n3 = "3";
  static const String n4 = "4";
  static const String n5 = "5";
  static const String n6 = "6";
  static const String n7 = "7";
  static const String n8 = "8";
  static const String n9 = "9";
  static const String dot = ".";
  static const String add = "+";
  static const String subtract = "-";
  static const String multiply = "*";
  static const String divide = "/";
  static const String sqrt = "√";
  static const String del = "DEL";
  static const String clr = "CLR";
  static const String calculate = "=";
  static const String per = "%";

  static const List<String> buttonValues = [
    n7, n8, n9, del,
    n4, n5, n6, add,
    n1, n2, n3, subtract,
    n0, dot, calculate, multiply,
    clr, per, sqrt, divide,
  ];
}
