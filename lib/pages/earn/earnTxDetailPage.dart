import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txIncentiveData.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class EarnTxDetailPage extends StatelessWidget {
  EarnTxDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/karura/earn/incentive/tx';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final TxDexIncentiveData tx = ModalRoute.of(context).settings.arguments;

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    return TxDetail(
      success: tx.isSuccess,
      action: tx.event,
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime:
          Fmt.dateTime(DateFormat("yyyy-MM-ddTHH:mm:ss").parse(tx.time, true)),
      networkName: networkName,
      infoItems: [
        TxDetailInfoItem(
          label: 'Event',
          content: Text(tx.event, style: amountStyle),
        ),
        TxDetailInfoItem(
          label: dic['earn.stake.pool'],
          content: Text(tx.poolId, style: amountStyle),
        ),
        TxDetailInfoItem(
          label:
              I18n.of(context).getDic(i18n_full_dic_karura, 'common')['amount'],
          content: Text(tx.amountShare, style: amountStyle),
        )
      ],
    );
  }
}
