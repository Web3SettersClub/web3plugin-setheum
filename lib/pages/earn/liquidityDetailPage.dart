import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3plugin_setheum/api/types/txLiquidityData.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class EarnLiquidityDetailPage extends StatelessWidget {
  EarnLiquidityDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/karura/earn/dex/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final TxDexLiquidityData tx = ModalRoute.of(context).settings.arguments;

    final List<TxDetailInfoItem> items = [];
    switch (tx.action) {
      case TxDexLiquidityData.actionDeposit:
        items.addAll([
          TxDetailInfoItem(
            label: dic['earn.add'],
            content: Text(tx.amountLeft, style: amountStyle),
          ),
          TxDetailInfoItem(
            label: dic['earn.add'],
            content: Text(tx.amountRight, style: amountStyle),
          )
        ]);
        break;
      case TxDexLiquidityData.actionWithdraw:
        items.add(TxDetailInfoItem(
          label: dic['dex.pay'],
          content: Text(tx.amountShare, style: amountStyle),
        ));
        break;
    }

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    return TxDetail(
      success: tx.isSuccess,
      action: tx.action,
      blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime: Fmt.dateTime(DateTime.parse(tx.time)),
      networkName: networkName,
      infoItems: items,
    );
  }
}
