import 'dart:js' as js;

dynamic get jsContext => js.context;

void callJsMethod(String method, [List? args]) {
  try {
    js.context.callMethod(method, args);
  } catch (_) {}
}

dynamic getJsProperty(String property) {
  try {
    return js.context[property];
  } catch (_) {
    return null;
  }
}

void setJsProperty(String property, dynamic value) {
  try {
    js.context[property] = value;
  } catch (_) {}
}
