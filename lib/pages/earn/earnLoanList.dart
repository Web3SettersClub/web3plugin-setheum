import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/pages/loan/loanPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';

class EarnLoanList extends StatefulWidget {
  EarnLoanList(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  @override
  _EarnLoanListState createState() => _EarnLoanListState();
}

class _EarnLoanListState extends State<EarnLoanList> {
  Future<void> _fetchData() async {
    await widget.plugin.service.loan
        .queryLoanTypes(widget.keyring.current.address);

    final priceQueryTokens =
        widget.plugin.store.loan.loanTypes.map((e) => e.token).toList();
    priceQueryTokens.add(widget.plugin.networkState.tokenSymbol[0]);
    widget.plugin.service.assets.queryMarketPrices(priceQueryTokens);

    if (mounted) {
      widget.plugin.service.loan
          .subscribeAccountLoans(widget.keyring.current.address);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // todo: fix this after new acala online
      final bool enabled = widget.plugin.basic.name == 'acala'
          ? ModalRoute.of(context).settings.arguments
          : true;
      if (enabled) {
        _fetchData();
      } else {
        widget.plugin.store.loan.setLoansLoading(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.plugin.service.loan.unsubscribeAccountLoans();
  }

  @override
  Widget build(BuildContext context) {
    final stableCoinDecimals = widget.plugin.networkState.tokenDecimals[
        widget.plugin.networkState.tokenSymbol.indexOf(karura_stable_coin)];
    final incentiveTokenSymbol = widget.plugin.networkState.tokenSymbol[0];
    return Observer(
      builder: (_) {
        final loans = widget.plugin.store.loan.loans.values.toList();
        loans.retainWhere((loan) =>
            loan.debits > BigInt.zero || loan.collaterals > BigInt.zero);

        final isDataLoading =
            widget.plugin.store.loan.loansLoading && loans.length == 0;

        return isDataLoading
            ? Container(
                height: MediaQuery.of(context).size.width / 2,
                child: CupertinoActivityIndicator(),
              )
            : CollateralIncentiveList(
                plugin: widget.plugin,
                loans: widget.plugin.store.loan.loans,
                tokenIcons: widget.plugin.tokenIcons,
                totalCDPs: widget.plugin.store.loan.totalCDPs,
                incentives: widget.plugin.store.earn.incentives.loans,
                rewards: widget.plugin.store.loan.collateralRewardsV2,
                marketPrices: widget.plugin.store.assets.marketPrices,
                collateralDecimals: stableCoinDecimals,
                incentiveTokenSymbol: incentiveTokenSymbol,
              );
      },
    );
  }
}
