import 'dart:async';

import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';

class AcalaServiceHoma {
  AcalaServiceHoma(this.plugin);

  final PluginSetheum plugin;

  Future<List> queryHomaLiteStakingPool() async {
    final List res = await plugin.sdk.webView.evalJavascript('Promise.all(['
        'api.query.homaLite.stakingCurrencyMintCap(),'
        'api.query.homaLite.totalStakingCurrency(),'
        'api.query.tokens.totalIssuance({ Token: "L$relay_chain_token_symbol" })'
        '])');
    return res;
  }

  // Future<Map> queryHomaUserInfo(String address) async {
  //   final Map res = await plugin.sdk.webView
  //       .evalJavascript('acala.fetchHomaUserInfo(api, "$address")');
  //   return res;
  // }

  Future<Map> queryHomaRedeemAmount(double input, int redeemType, era) async {
    final Map res = await plugin.sdk.webView.evalJavascript(
        'acala.queryHomaRedeemAmount(api, $input, $redeemType, $era)');
    return res;
  }

  Future<Map> calcHomaMintAmount(double input) async {
    final Map res = await plugin.sdk.webView
        .evalJavascript('acala.calcHomaMintAmount(api, $input)');
    return res;
  }

  Future<Map> calcHomaRedeemAmount(
      String address, double input, bool isByDex) async {
    final Map res = await plugin.sdk.webView.evalJavascript(
        'acala.calcHomaRedeemAmount(api,"$address", $input,$isByDex)');
    return res;
  }

  Future<dynamic> redeemRequested(String address) async {
    final dynamic res = await plugin.sdk.webView
        .evalJavascript('acala.queryRedeemRequest(api,"$address")');
    return res;
  }
}
