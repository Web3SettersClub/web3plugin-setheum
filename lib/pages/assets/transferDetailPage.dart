import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3plugin_setheum/api/types/transferData.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/format.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class TransferDetailPage extends StatelessWidget {
  TransferDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/assets/token/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_karura, 'common');

    final TransferData tx = ModalRoute.of(context).settings.arguments;

    final String txType =
        tx.from == keyring.current.address ? dic['transfer'] : dic['receive'];

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    return TxDetail(
      success: tx.isSuccess,
      action: txType,
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime: Fmt.dateTime(DateTime.parse(tx.timestamp)),
      networkName: networkName,
      infoItems: <TxDetailInfoItem>[
        TxDetailInfoItem(
          label: dic['amount'],
          content: Text(
            '${tx.amount} ${PluginFmt.tokenView(tx.token)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TxDetailInfoItem(
          label: 'From',
          content: Text(Fmt.address(tx.from)),
          copyText: tx.from,
        ),
        TxDetailInfoItem(
          label: 'To',
          content: Text(Fmt.address(tx.to)),
          copyText: tx.to,
        )
      ],
    );
  }
}
