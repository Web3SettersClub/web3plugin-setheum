import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:web3plugin_setheum/api/types/dexPoolInfoData.dart';
import 'package:web3plugin_setheum/pages/earn/addLiquidityPage.dart';
import 'package:web3plugin_setheum/pages/earn/withdrawLiquidityPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/format.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/infoItem.dart';
import 'package:web3wallet_ui/components/listTail.dart';
import 'package:web3wallet_ui/components/outlinedButtonSmall.dart';
import 'package:web3wallet_ui/components/roundedCard.dart';
import 'package:web3wallet_ui/components/tokenIcon.dart';
import 'package:web3wallet_ui/utils/format.dart';

class DexPoolList extends StatefulWidget {
  DexPoolList(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  @override
  _DexPoolListState createState() => _DexPoolListState();
}

class _DexPoolListState extends State<DexPoolList> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Map _poolInfoMap = {};

  Future<void> _updateData() async {
    await widget.plugin.service.earn.getDexPools();
    final pools = widget.plugin.store.earn.dexPools.toList();
    final List res = await widget.plugin.sdk.webView.evalJavascript(
        'Promise.all([${pools.map((e) => 'api.query.dex.liquidityPool(${jsonEncode(e.tokens)})').join(',')}])');
    final poolInfoMap = {};
    pools.asMap().forEach((i, e) {
      final poolId = e.tokens.map((e) => e['token']).toList().join('-');
      poolInfoMap[poolId] = res[i];
    });
    if (mounted) {
      setState(() {
        _poolInfoMap = poolInfoMap;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final dexPools = widget.plugin.store.earn.dexPools.toList();
      dexPools.retainWhere((e) => e.provisioning == null);
      return RefreshIndicator(
        key: _refreshKey,
        onRefresh: _updateData,
        child: dexPools.length == 0
            ? ListView(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                children: [
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      child: ListTail(isEmpty: true, isLoading: false),
                    ),
                  )
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                itemCount: dexPools.length,
                itemBuilder: (_, i) {
                  final poolId =
                      dexPools[i].tokens.map((e) => e['token']).join('-');
                  final poolAmount = _poolInfoMap[poolId] as List;
                  return _DexPoolCard(
                    pool: dexPools[i],
                    poolAmount: poolAmount,
                    tokenIcons: widget.plugin.tokenIcons,
                  );
                },
              ),
      );
    });
  }
}

class _DexPoolCard extends StatelessWidget {
  _DexPoolCard({this.pool, this.poolAmount, this.tokenIcons});

  final DexPoolData pool;
  final List poolAmount;
  final Map<String, Widget> tokenIcons;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final primaryColor = Theme.of(context).primaryColor;
    final colorGrey = Theme.of(context).unselectedWidgetColor;

    final tokenPair = pool.tokens.map((e) => e['token']).toList();
    final tokenPairView =
        tokenPair.map((e) => PluginFmt.tokenView(e)).join('-');
    final poolId = tokenPair.join('-');

    BigInt amountLeft;
    BigInt amountRight;
    double ratio = 0;
    if (poolAmount != null) {
      amountLeft = Fmt.balanceInt(poolAmount[0].toString());
      amountRight = Fmt.balanceInt(poolAmount[1].toString());
      ratio = amountLeft > BigInt.zero ? amountRight / amountLeft : 0;
    }

    return RoundedCard(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                child: TokenIcon(poolId, tokenIcons),
                margin: EdgeInsets.only(right: 8),
              ),
              Expanded(
                  child: Text(
                tokenPairView,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorGrey,
                ),
              )),
            ],
          ),
          Divider(height: 24),
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: [
                InfoItem(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: PluginFmt.tokenView(tokenPair[0]),
                  content: amountLeft == null
                      ? '--'
                      : Fmt.priceFloorBigInt(amountLeft, pool.pairDecimals[0]),
                ),
                InfoItem(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: PluginFmt.tokenView(tokenPair[1]),
                  content: amountRight == null
                      ? '--'
                      : Fmt.priceFloorBigInt(amountRight, pool.pairDecimals[1]),
                ),
                InfoItem(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  title: dic['boot.ratio'],
                  content: '1 : ${ratio.toStringAsFixed(4)}',
                ),
              ],
            ),
          ),
          Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButtonSmall(
                  content: dic['dex.lp.remove'],
                  active: false,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  onPressed: () => Navigator.of(context).pushNamed(
                      WithdrawLiquidityPage.route,
                      arguments: poolId),
                ),
              ),
              Expanded(
                child: OutlinedButtonSmall(
                  content: dic['dex.lp.add'],
                  active: true,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AddLiquidityPage.route, arguments: poolId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
