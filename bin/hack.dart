import 'dart:async';

import 'package:ruby_dart_brewery/ruby_dart_brewery.dart';

void main() {

  Future.forEach(['be', 'dev', 'stable'], (channel) {
    return _printChannel(channel);
  });
}

Future _printChannel(String channel) {
  return getVersionInfo(channel).then((versionInfo) {
    print(versionInfo);
  });
}
