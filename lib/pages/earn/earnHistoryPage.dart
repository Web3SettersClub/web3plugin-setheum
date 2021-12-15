import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txIncentiveData.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/common/constants/subQuery.dart';
import 'package:web3plugin_setheum/pages/earn/earnTxDetailPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/listTail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class EarnHistoryPage extends StatelessWidget {
  EarnHistoryPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static const String route = '/karura/earn/txs';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['loan.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Query(
          options: QueryOptions(
            document: gql(dexStakeQuery),
            variables: <String, String>{
              'account': keyring.current.address,
            },
          ),
          builder: (
            QueryResult result, {
            Future<QueryResult> Function() refetch,
            FetchMore fetchMore,
          }) {
            if (result.data == null) {
              return Container(
                height: MediaQuery.of(context).size.height / 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CupertinoActivityIndicator()],
                ),
              );
            }

            final nodes =
                List.of(result.data['incentiveActions']['nodes']).toList();
            nodes.removeWhere(
                (e) => jsonDecode(e['data'][1]['value'])['loans'] != null);
            final list = nodes
                .map((i) => TxDexIncentiveData.fromJson(
                    i as Map,
                    karura_stable_coin,
                    plugin.networkState.tokenSymbol,
                    plugin.networkState.tokenDecimals))
                .toList();

            return ListView.builder(
              itemCount: list.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == list.length) {
                  return ListTail(isEmpty: list.length == 0, isLoading: false);
                }

                final detail = list[i];
                String amount = '';
                bool isReceive = true;
                switch (detail.event) {
                  case TxDexIncentiveData.actionStake:
                    amount = detail.amountShare;
                    isReceive = false;
                    break;
                  case TxDexIncentiveData.actionClaimRewards:
                  case TxDexIncentiveData.actionPayoutRewards:
                  case TxDexIncentiveData.actionUnStake:
                    amount = detail.amountShare;
                    break;
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(amount, style: TextStyle(fontSize: 14)),
                    subtitle: Text(Fmt.dateTime(
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(detail.time, true))),
                    leading: SvgPicture.asset(
                        'packages/web3plugin_setheum/assets/images/${detail.isSuccess ? isReceive ? 'assets_down' : 'assets_up' : 'tx_failed'}.svg',
                        width: 32),
                    trailing: Text(
                      detail.event,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        EarnTxDetailPage.route,
                        arguments: detail,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

const earn_actions_map = {
  'addLiquidity': 'earn.add',
  'removeLiquidity': 'earn.remove',
  'depositDexShare': 'earn.stake',
  'withdrawDexShare': 'earn.unStake',
  'claimRewards': 'earn.claim',
};
