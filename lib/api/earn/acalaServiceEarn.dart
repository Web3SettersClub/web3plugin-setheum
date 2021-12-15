import 'dart:async';

import 'package:web3plugin_setheum/web3plugin_setheum.dart';

class AcalaServiceEarn {
  AcalaServiceEarn(this.plugin);

  final PluginSetheum plugin;

  Future<Map> queryIncentives() async {
    final Map res =
        await plugin.sdk.webView.evalJavascript('acala.queryIncentives(api)');
    return res;
  }
}
