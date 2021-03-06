import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txHomaData.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/txDetail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class HomaTxDetailPage extends StatelessWidget {
  HomaTxDetailPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static final String route = '/karura/homa/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    final decimals = plugin.networkState.tokenDecimals;
    final symbols = plugin.networkState.tokenSymbol;

    final TxHomaData tx = ModalRoute.of(context).settings.arguments;

    final symbol = relay_chain_token_symbol;
    final nativeDecimal = decimals[symbols.indexOf(symbol)];
    final liquidDecimal = decimals[symbols.indexOf('L$symbol')];

    final amountStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    final infoItems = <TxDetailInfoItem>[];

    switch (tx.action) {
      case TxHomaData.actionMint:
        infoItems.addAll([
          TxDetailInfoItem(
            label: dic['dex.pay'],
            content: Text(
                '${Fmt.priceFloorBigInt(tx.amountPay, nativeDecimal)} $symbol',
                style: amountStyle),
          ),
          TxDetailInfoItem(
            label: dic['dex.receive'],
            content: Text(
                '${Fmt.priceFloorBigInt(tx.amountReceive, liquidDecimal)} L$symbol',
                style: amountStyle),
          )
        ]);
        break;
      case TxHomaData.actionRedeem:
        infoItems.add(TxDetailInfoItem(
          label: dic['dex.pay'],
          content: Text(
              '${Fmt.priceFloorBigInt(tx.amountPay, liquidDecimal)} L$symbol',
              style: amountStyle),
        ));
        break;
      case TxHomaData.actionRedeemed:
        infoItems.add(TxDetailInfoItem(
          label: dic['dex.receive'],
          content: Text(
              '${Fmt.priceFloorBigInt(tx.amountReceive, nativeDecimal)} $symbol',
              style: amountStyle),
        ));
        break;
      case TxHomaData.actionRedeemCancel:
        infoItems.add(TxDetailInfoItem(
          label: dic['dex.receive'],
          content: Text(
              '${Fmt.priceFloorBigInt(tx.amountReceive, liquidDecimal)} L$symbol',
              style: amountStyle),
        ));
    }

    return TxDetail(
      success: tx.isSuccess,
      action: tx.action,
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime:
          Fmt.dateTime(DateFormat("yyyy-MM-ddTHH:mm:ss").parse(tx.time, true)),
      networkName: plugin.basic.name,
      infoItems: infoItems,
    );
  }
}
