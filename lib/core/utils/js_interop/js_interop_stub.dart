/// No-op fallback implementation for Non-Web platforms (Android, iOS, Desktop)
class JsContextStub {
  const JsContextStub();
  dynamic callMethod(String method, [List? args]) => null;
  bool hasProperty(String property) => false;
  dynamic operator [](String key) => null;
  void operator []=(String key, dynamic value) {}
}

const jsStub = JsContextStub();
dynamic get jsContext => jsStub;

void callJsMethod(String method, [List? args]) {}
dynamic getJsProperty(String property) => null;
void setJsProperty(String property, dynamic value) {}
