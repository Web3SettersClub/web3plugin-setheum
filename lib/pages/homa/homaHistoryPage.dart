import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:web3plugin_setheum/api/types/txHomaData.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/common/constants/subQuery.dart';
import 'package:web3plugin_setheum/pages/homa/homaTxDetailPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/listTail.dart';
import 'package:web3wallet_ui/utils/format.dart';

class HomaHistoryPage extends StatelessWidget {
  HomaHistoryPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static const String route = '/karura/homa/txs';

  @override
  Widget build(BuildContext context) {
    final symbols = plugin.networkState.tokenSymbol;
    final decimals = plugin.networkState.tokenDecimals;
    final symbol = relay_chain_token_symbol;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            I18n.of(context).getDic(i18n_full_dic_karura, 'acala')['loan.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Query(
          options: QueryOptions(
            document: gql(homaQuery),
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

            final list = List.of(result.data['homaActions']['nodes'])
                .map((i) => TxHomaData.fromJson(i as Map))
                .toList();

            final nativeDecimal = decimals[symbols.indexOf(symbol)];
            final liquidDecimal = decimals[symbols.indexOf('L$symbol')];

            return ListView.builder(
              itemCount: list.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == list.length) {
                  return ListTail(isEmpty: list.length == 0, isLoading: false);
                }

                final detail = list[i];

                String amountPay = '';
                String amountReceive = '';

                switch (detail.action) {
                  case TxHomaData.actionMint:
                    amountPay =
                        '${Fmt.priceFloorBigInt(detail.amountPay, nativeDecimal)} $symbol';
                    amountReceive =
                        '${Fmt.priceFloorBigInt(detail.amountReceive, liquidDecimal)} L$symbol';
                    break;
                  case TxHomaData.actionRedeem:
                    amountPay =
                        '${Fmt.priceFloorBigInt(detail.amountPay, liquidDecimal)} L$symbol';
                    break;
                  case TxHomaData.actionRedeemed:
                    amountReceive =
                        '${Fmt.priceFloorBigInt(detail.amountReceive, nativeDecimal)} $symbol';
                    break;
                  case TxHomaData.actionRedeemCancel:
                    amountReceive =
                        '${Fmt.priceFloorBigInt(detail.amountPay, liquidDecimal)} L$symbol';
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text('${detail.action} $amountReceive'),
                    subtitle: Text(Fmt.dateTime(
                        DateFormat("yyyy-MM-ddTHH:mm:ss")
                            .parse(detail.time, true))),
                    leading: SvgPicture.asset('assets/images/assets_up.svg',
                        width: 32),
                    trailing: Text(
                      amountPay,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.end,
                    ),
                    onTap: () => Navigator.of(context)
                        .pushNamed(HomaTxDetailPage.route, arguments: detail),
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
