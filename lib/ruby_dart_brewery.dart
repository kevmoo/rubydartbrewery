library ruby_dart_brewery;

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'src/constants.dart';
export 'src/constants.dart';

Future<VersionInfo> getVersionInfo(String channel, [int revision]) {
  var path = getChannelUrl(channel);

  if (revision == null) {
    path = p.join(path, 'latest');
  } else {
    path = p.join(path, revision.toString());
  }

  path = p.join(path, 'VERSION');

  return http.read(path).then(JSON.decode).then((json) {
    var info = new VersionInfo.fromMap(json);
    if (revision != null && revision != info.revision) {
      print("WEIRD: requested revision $revision, got '${info.revision}.");
    }
    return info;
  });
}

Future getPublishedBinary(String channel, String binaryPath) {
  VersionInfo latestInfo, revisionInfo;

  return getVersionInfo(channel).then((info) {
    print('$channel\tLatest revision: ${info.revision}');
    latestInfo = info;

    return getPublishedVersionInfo(channel, info.revision);
  }).then((info) {
    print('$channel\tPublished revision: ${info.revision}');
    revisionInfo = info;

    // Now try to get the binary
  });

  // get 'latest' version info

  // start trying to get the version info

}

Future<VersionInfo> getPublishedVersionInfo(String channel, int startRevision, [int attempts = 100]) {
  assert(attempts > 0);
  var attemptsLeft = attempts;
  var completer = new Completer<VersionInfo>();

  void work(int revision) {
    attemptsLeft--;
    if(attempts <= 0) {
      completer.completeError('Could not find published version for $channel starting at revision $startRevision in $attempts attemts.');
      return;
    }

    _getPublishedVersionInfoOrNull(channel, revision).then((info) {
      if (info == null) {
        work(revision - 1);
      } else {
        completer.complete(info);
      }
    });
  }

  work(startRevision);

  return completer.future;
}

Future<VersionInfo> _getPublishedVersionInfoOrNull(String channel, int revision) {
  return getVersionInfo(channel, revision).catchError((err, stack) {
    print('\terror getting $channel - $revision');
    return null;
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
