import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txLoanData.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/format.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class LoanTxDetailPage extends StatelessWidget {
  LoanTxDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/karura/loan/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final TxLoanData tx = ModalRoute.of(context).settings.arguments;

    final List<TxDetailInfoItem> items = [
      TxDetailInfoItem(
        label: 'Event',
        content: Text(tx.event, style: amountStyle),
      ),
      TxDetailInfoItem(
        label: dic['txs.action'],
        content: Text(dic['loan.${tx.actionType}'], style: amountStyle),
      )
    ];
    if (tx.collateral != BigInt.zero) {
      items.add(TxDetailInfoItem(
        label: tx.collateral > BigInt.zero
            ? dic['loan.deposit']
            : dic['loan.withdraw'],
        content: Text('${tx.amountCollateral} ${PluginFmt.tokenView(tx.token)}',
            style: amountStyle),
      ));
    }
    if (tx.debit != BigInt.zero) {
      items.add(TxDetailInfoItem(
        label: tx.debit < BigInt.zero ? dic['loan.payback'] : dic['loan.mint'],
        content: Text('${tx.amountDebit} $karura_stable_coin_view',
            style: amountStyle),
      ));
    }

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    return TxDetail(
      success: tx.isSuccess,
      action: dic['loan.${tx.actionType}'],
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime:
          Fmt.dateTime(DateFormat("yyyy-MM-ddTHH:mm:ss").parse(tx.time, true)),
      networkName: networkName,
      infoItems: items,
    );
  }
}
