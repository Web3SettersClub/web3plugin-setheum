import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txSwapData.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/format.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class SwapDetailPage extends StatelessWidget {
  SwapDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/karura/swap/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final decimals = plugin.networkState.tokenDecimals;
    final symbols = plugin.networkState.tokenSymbol;

    final TxSwapData tx = ModalRoute.of(context).settings.arguments;
    final token0 = PluginFmt.tokenView(tx.tokenPay);
    final token1 = PluginFmt.tokenView(tx.tokenReceive);
    final tokenLP = '$token0-$token1 LP';
    final amount0 =
        Fmt.balance(tx.amountPay, decimals[symbols.indexOf(tx.tokenPay)]);
    final amount1 = Fmt.balance(
        tx.amountReceive, decimals[symbols.indexOf(tx.tokenReceive)]);
    final amountLP =
        Fmt.balance(tx.amountShare, decimals[symbols.indexOf(tx.tokenPay)]);

    final amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    String networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName.split('-')[0]}-testnet';
    }
    final List<TxDetailInfoItem> items = [];
    switch (tx.action) {
      case "swapWithExactSupply":
      case "swapWithExactTarget":
        items.addAll([
          TxDetailInfoItem(
            label: dic['dex.pay'],
            content: Text('$amount0 $token0', style: amountStyle),
          ),
          TxDetailInfoItem(
            label: dic['dex.receive'],
            content: Text('$amount1 $token1', style: amountStyle),
          )
        ]);
        break;
      case "addProvision":
        items.add(TxDetailInfoItem(
            label: dic['dex.pay'],
            content: Text(
              '$amount0 $token0\n'
              '+ $amount1 $token1',
              style: amountStyle,
              textAlign: TextAlign.right,
            )));
        break;
      case "addLiquidity":
        items.addAll([
          TxDetailInfoItem(
            label: dic['dex.pay'],
            content: Text(
                '$amount0 $token0\n'
                '+ $amount1 $token1',
                textAlign: TextAlign.right,
                style: amountStyle),
          ),
          TxDetailInfoItem(
            label: dic['dex.receive'],
            content: Text('$amountLP $tokenLP', style: amountStyle),
          )
        ]);
        break;
      case "removeLiquidity":
        items.addAll([
          TxDetailInfoItem(
            label: dic['dex.pay'],
            content: Text('$amountLP $tokenLP', style: amountStyle),
          ),
          TxDetailInfoItem(
            label: dic['dex.receive'],
            content: Text(
                '$amount0 $token0\n'
                '+ $amount1 $token1',
                textAlign: TextAlign.right,
                style: amountStyle),
          )
        ]);
    }

    return TxDetail(
      success: tx.isSuccess,
      action: tx.action,
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime:
          Fmt.dateTime(DateFormat("yyyy-MM-ddTHH:mm:ss").parse(tx.time, true)),
      networkName: networkName,
      infoItems: items,
    );
  }
}
