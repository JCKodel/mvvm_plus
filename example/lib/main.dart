import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:bilocator/bilocator.dart';

void main() => runApp(myApp());

Widget myApp() => Bilocator<ColorService>(
    builder: () => ColorService(milliSeconds: 1500),
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Bilocator<ColorService>(
            builder: () => ColorService(milliSeconds: 2250), location: Location.tree, child: Page())));

class IncrementButton extends View<IncrementButtonViewModel> {
  IncrementButton({super.key}) : super(builder: () => IncrementButtonViewModel());

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: viewModel.incrementCounter,
      child: Text(viewModel.buttonText, style: const TextStyle(fontSize: 24)),
    );
  }
}

class IncrementButtonViewModel extends ViewModel {
  late final isNumber = createProperty<bool>(false);
  String get buttonText => isNumber.value ? '+1' : '+a';
  void incrementCounter() {
    isNumber.value ? get<PageViewModel>().incrementNumber() : get<PageViewModel>().incrementLetter();
    isNumber.value = !isNumber.value;
  }
}

class Page extends View<PageViewModel> {
  Page({super.key}) : super(location: Location.registry, builder: () => PageViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(viewModel.letterCount.value,
                style: TextStyle(fontSize: 64, color: listenTo<ColorService>(context: context).color.value)),
            Text(viewModel.numberCounter.value.toString(),
                style: TextStyle(fontSize: 64, color: listenTo<ColorService>().color.value)),
          ]),
        ])),
        floatingActionButton: IncrementButton());
  }
}

class PageViewModel extends ViewModel {
  late final numberCounter = createProperty<int>(0);
  late final letterCount = createProperty<String>('a');

  void incrementNumber() => numberCounter.value = numberCounter.value == 9 ? 0 : numberCounter.value + 1;
  void incrementLetter() =>
      letterCount.value = letterCount.value == 'z' ? 'a' : String.fromCharCode(letterCount.value.codeUnits[0] + 1);
}

class ColorService extends Model {
  ColorService({required int milliSeconds}) {
    _timer = Timer.periodic(Duration(milliseconds: milliSeconds), (_) {
      color.value = <Color>[Colors.red, Colors.black, Colors.blue, Colors.orange][++_counter % 4];
    });
  }

  int _counter = 0;
  late final color = createProperty<Color>(Colors.orange);
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
