library ruby_dart_brewery;

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'src/constants.dart';
export 'src/constants.dart';

Future<VersionInfo> getVersionInfo(String channel, [int version]) {
  var path = getChannelUrl(channel);

  if (version == null) {
    path = p.join(path, 'latest');
  } else {
    path = p.join(path, version.toString());
  }

  path = p.join(path, 'VERSION');

  return http.read(path).then(JSON.decode).then((json) {
    return new VersionInfo.fromMap(json);
  });
}

class VersionInfo {
  final int revision;
  final String version;
  final String dateString;

  VersionInfo(this.revision, this.version, this.dateString);

  factory VersionInfo.fromMap(Map<String, dynamic> map) {
    return new VersionInfo(int.parse(map['revision']), map['version'], map['date']);
  }

  String toString() => '$version @ $revision - $dateString';
}

String getChannelUrl(String channel) {
  switch(channel) {
    case 'be':
      return beRootUrl;
    case 'dev':
      return devRootUrl;
    case 'stable':
      return stableRootUrl;
    default:
      throw new ArgumentError('Channel "$channel" is unkwown.');
  }
}
