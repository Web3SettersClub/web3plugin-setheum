import 'package:web3plugin_setheum/api/acalaApi.dart';
import 'package:web3plugin_setheum/api/types/loanType.dart';
import 'package:web3plugin_setheum/api/types/stakingPoolInfoData.dart';
import 'package:web3plugin_setheum/common/constants/base.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/store/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_ui/utils/format.dart';

class ServiceLoan {
  ServiceLoan(this.plugin, this.keyring)
      : api = plugin.api,
        store = plugin.store;

  final PluginSetheum plugin;
  final Keyring keyring;
  final AcalaApi api;
  final PluginStore store;

  void _calcLiquidTokenPrice(
      Map<String, BigInt> prices, HomaLitePoolInfoData poolInfo) {
    // LDOT price may lost precision here
    final relayToken = relay_chain_token_symbol;
    final exchangeRate = poolInfo.staked > BigInt.zero
        ? (poolInfo.liquidTokenIssuance / poolInfo.staked)
        : Fmt.balanceDouble(
            plugin.networkConst['homaLite']['defaultExchangeRate'],
            acala_price_decimals);
    prices['L$relayToken'] = Fmt.tokenInt(
        (Fmt.bigIntToDouble(
                    prices[relayToken], plugin.networkState.tokenDecimals[0]) /
                exchangeRate)
            .toString(),
        plugin.networkState.tokenDecimals[0]);
  }

  Future<double> _fetchNativeTokenPrice() async {
    final output = await api.swap.queryTokenSwapAmount('1', null,
        [plugin.networkState.tokenSymbol[0], karura_stable_coin], '0.1');
    return output.amount;
  }

  Map<String, LoanData> _calcLoanData(
    List loans,
    List<LoanType> loanTypes,
    Map<String, BigInt> prices,
  ) {
    final data = Map<String, LoanData>();
    final stableCoinDecimals = plugin.networkState.tokenDecimals[
        plugin.networkState.tokenSymbol.indexOf(karura_stable_coin)];
    loans.forEach((i) {
      final String token = i['currency']['token'];
      final tokenDecimals = plugin.networkState
          .tokenDecimals[plugin.networkState.tokenSymbol.indexOf(token)];
      data[token] = LoanData.fromJson(
        Map<String, dynamic>.from(i),
        loanTypes.firstWhere((t) => t.token == token),
        prices[token] ?? BigInt.zero,
        stableCoinDecimals,
        tokenDecimals,
      );
    });
    return data;
  }

  Map<String, double> _calcCollateralIncentiveRate(
      List<CollateralIncentiveData> incentives) {
    final blockTime = plugin.networkConst['babe'] == null
        ? BLOCK_TIME_DEFAULT
        : int.parse(plugin.networkConst['babe']['expectedBlockTime']);
    final epoch =
        int.parse(plugin.networkConst['incentives']['accumulatePeriod']);
    final epochOfYear = SECONDS_OF_YEAR * 1000 / blockTime / epoch;
    final res = Map<String, double>();
    incentives.forEach((e) {
      res[e.token] = Fmt.bigIntToDouble(
              e.incentive, plugin.networkState.tokenDecimals[0]) *
          epochOfYear;
    });
    return res;
  }

  Future<void> queryLoanTypes(String address) async {
    if (address == null) return;

    await plugin.service.earn.updateAllDexPoolInfo();
    final res = await api.loan.queryLoanTypes();
    store.loan.setLoanTypes(res);

    queryTotalCDPs();
  }

  Future<void> subscribeAccountLoans(String address) async {
    if (address == null) return;

    store.loan.setLoansLoading(true);

    // 1. subscribe all token prices, callback triggers per 5s.
    api.assets.subscribeTokenPrices((Map<String, BigInt> prices) async {
      // 2. we need homa staking pool info to calculate price of LDOT
      final stakingPoolInfo = await api.homa.queryHomaLiteStakingPool();
      store.homa.setHomaLitePoolInfoData(stakingPoolInfo);

      // 3. set prices
      _calcLiquidTokenPrice(prices, stakingPoolInfo);
      // we may not need ACA/KAR prices
      // prices['ACA'] = Fmt.tokenInt(data[1].toString(), acala_price_decimals);

      store.assets.setPrices(prices);

      // 4. update collateral incentive rewards
      queryCollateralRewardsV2(address);

      // 4. we need loanTypes & prices to get account loans
      final loans = await api.loan.queryAccountLoans(address);
      if (store.loan.loansLoading) {
        store.loan.setLoansLoading(false);
      }
      if (loans != null &&
          loans.length > 0 &&
          store.loan.loanTypes.length > 0 &&
          keyring.current.address == address) {
        store.loan.setAccountLoans(
            _calcLoanData(loans, store.loan.loanTypes, prices));
      }
    });
  }

  Future<void> queryTotalCDPs() async {
    final res = await api.loan
        .queryTotalCDPs(store.loan.loanTypes.map((e) => e.token).toList());
    store.loan.setTotalCDPs(res);
  }

  Future<void> queryCollateralRewardsV2(String address) async {
    final res = await api.loan.queryCollateralRewardsV2(
        store.loan.loanTypes.map((e) => e.token).toList(), address);
    store.loan.setCollateralRewardsV2(res);
  }

  void unsubscribeAccountLoans() {
    api.assets.unsubscribeTokenPrices();
    store.loan.setLoansLoading(true);
  }
}
