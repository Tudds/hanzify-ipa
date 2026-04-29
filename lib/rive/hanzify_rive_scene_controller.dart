import 'package:rive/rive.dart';

class HanzifyRiveSceneController {
  StateMachineController? _controller;

  void bind(StateMachineController controller) {
    _controller = controller;
  }

  void fire(String inputName) {
    final input = _controller?.findInput<bool>(inputName);
    if (input is SMITrigger) {
      input.fire();
    }
  }

  void setBool(String inputName, bool value) {
    final input = _controller?.findInput<bool>(inputName);
    if (input is SMIBool) {
      input.value = value;
    }
  }

  void setNumber(String inputName, double value) {
    final input = _controller?.findInput<double>(inputName);
    if (input is SMINumber) {
      input.value = value;
    }
  }
}
