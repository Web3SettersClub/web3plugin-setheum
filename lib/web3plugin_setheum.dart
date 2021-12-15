library web3plugin_setheum;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web3plugin_setheum/api/acalaApi.dart';
import 'package:web3plugin_setheum/api/acalaService.dart';
import 'package:web3plugin_setheum/common/constants/base.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/common/constants/nodeList.dart';
import 'package:web3plugin_setheum/pages/acalaEntry.dart';
import 'package:web3plugin_setheum/pages/assets/tokenDetailPage.dart';
import 'package:web3plugin_setheum/pages/assets/transferDetailPage.dart';
import 'package:web3plugin_setheum/pages/assets/transferPage.dart';
import 'package:web3plugin_setheum/pages/currencySelectPage.dart';
import 'package:web3plugin_setheum/pages/earn/LPStakePage.dart';
import 'package:web3plugin_setheum/pages/earn/addLiquidityPage.dart';
import 'package:web3plugin_setheum/pages/earn/earnDetailPage.dart';
import 'package:web3plugin_setheum/pages/earn/earnHistoryPage.dart';
import 'package:web3plugin_setheum/pages/earn/earnPage.dart';
import 'package:web3plugin_setheum/pages/earn/earnTxDetailPage.dart';
import 'package:web3plugin_setheum/pages/earn/liquidityDetailPage.dart';
import 'package:web3plugin_setheum/pages/earn/withdrawLiquidityPage.dart';
import 'package:web3plugin_setheum/pages/gov/democracy/proposalDetailPage.dart';
import 'package:web3plugin_setheum/pages/gov/democracy/referendumVotePage.dart';
import 'package:web3plugin_setheum/pages/gov/democracyPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanAdjustPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanCreatePage.dart';
import 'package:web3plugin_setheum/pages/loan/loanDepositPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanDetailPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanHistoryPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanTxDetailPage.dart';
import 'package:web3plugin_setheum/pages/nft/nftBurnPage.dart';
import 'package:web3plugin_setheum/pages/nft/nftDetailPage.dart';
import 'package:web3plugin_setheum/pages/nft/nftPage.dart';
import 'package:web3plugin_setheum/pages/nft/nftTransferPage.dart';
import 'package:web3plugin_setheum/pages/swap/bootstrapPage.dart';
import 'package:web3plugin_setheum/pages/swap/swapDetailPage.dart';
import 'package:web3plugin_setheum/pages/swap/swapHistoryPage.dart';
import 'package:web3plugin_setheum/pages/swap/swapPage.dart';
import 'package:web3plugin_setheum/service/graphql.dart';
import 'package:web3plugin_setheum/service/index.dart';
import 'package:web3plugin_setheum/store/cache/storeCache.dart';
import 'package:web3plugin_setheum/store/index.dart';
import 'package:web3wallet_sdk/api/types/networkParams.dart';
import 'package:web3wallet_sdk/plugin/homeNavItem.dart';
import 'package:web3wallet_sdk/plugin/index.dart';
import 'package:web3wallet_sdk/plugin/store/balances.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/storage/types/keyPairData.dart';
import 'package:web3wallet_ui/pages/accountQrCodePage.dart';
import 'package:web3wallet_ui/pages/txConfirmPage.dart';

class PluginSetheum extends Web3WalletPlugin {
  PluginSetheum({String name = plugin_name_setheum})
      : basic = PluginBasicData(
          name: name,
          genesisHash: plugin_genesis_hash,
          ss58: ss58_prefix_setheum,
          primaryColor: Colors.red,
          gradientColor: Color.fromARGB(255, 255, 76, 59),
          backgroundImage:
              AssetImage('packages/web3plugin_setheum/assets/images/bg.png'),
          icon: name == plugin_name_setheum
              ? Image.asset(
                  'packages/web3plugin_setheum/assets/images/tokens/KAR.png')
              : SvgPicture.asset(
                  'packages/web3plugin_setheum/assets/images/logo.svg'),
          iconDisabled: name == plugin_name_setheum
              ? Image.asset(
                  'packages/web3plugin_setheum/assets/images/logo_kar_gray.png')
              : SvgPicture.asset(
                  'packages/web3plugin_setheum/assets/images/logo.svg',
                  color: Color(0xFF9E9E9E),
                  width: 24,
                ),
          isTestNet: name != plugin_name_setheum,
          isXCMSupport: name == plugin_name_setheum,
          parachainId: '2000',
          jsCodeVersion: 23301,
        );

  @override
  final PluginBasicData basic;

  @override
  List<NetworkParams> get nodeList {
    return _randomList(node_list)
        .map((e) => NetworkParams.fromJson(e))
        .toList();
  }

  Map<String, Widget> _getTokenIcons() {
    final Map<String, Widget> all = {};
    acala_token_ids.forEach((token) {
      all[token] = Image.asset(
          'packages/web3plugin_setheum/assets/images/tokens/$token.png');
    });
    return all;
  }

  @override
  Map<String, Widget> get tokenIcons => _getTokenIcons();

  @override
  List<TokenBalanceData> get noneNativeTokensAll {
    return store?.assets?.tokenBalanceMap?.values?.toList();
  }

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    return [
      HomeNavItem(
        text: 'Karura',
        icon: SvgPicture.asset(
            'packages/web3plugin_setheum/assets/images/logo_kar_empty.svg',
            color: Theme.of(context).disabledColor),
        iconActive: Image.asset(
            'packages/web3plugin_setheum/assets/images/tokens/KAR.png'),
        content: AcalaEntry(this, keyring),
      )
    ];
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) =>
          TxConfirmPage(this, keyring, _service.getPassword),
      CurrencySelectPage.route: (_) => CurrencySelectPage(this),
      AccountQrCodePage.route: (_) => AccountQrCodePage(this, keyring),

      TokenDetailPage.route: (_) => ClientProvider(
            child: Builder(
              builder: (_) => TokenDetailPage(this, keyring),
            ),
            uri: GraphQLConfig['httpUri'],
          ),
      TransferPage.route: (_) => TransferPage(this, keyring),
      TransferDetailPage.route: (_) => TransferDetailPage(this, keyring),

      // loan pages
      LoanPage.route: (_) => LoanPage(this, keyring),
      LoanDetailPage.route: (_) => LoanDetailPage(this, keyring),
      LoanTxDetailPage.route: (_) => LoanTxDetailPage(this, keyring),
      LoanCreatePage.route: (_) => LoanCreatePage(this, keyring),
      LoanAdjustPage.route: (_) => LoanAdjustPage(this, keyring),
      LoanDepositPage.route: (_) => LoanDepositPage(this, keyring),
      LoanHistoryPage.route: (_) => ClientProvider(
            child: Builder(
              builder: (_) => LoanHistoryPage(this, keyring),
            ),
            uri: GraphQLConfig['httpUri'],
          ),
      // swap pages
      SwapPage.route: (_) => SwapPage(this, keyring),
      SwapHistoryPage.route: (_) => ClientProvider(
            child: Builder(
              builder: (_) => SwapHistoryPage(this, keyring),
            ),
            uri: GraphQLConfig['httpUri'],
          ),
      SwapDetailPage.route: (_) => SwapDetailPage(this, keyring),
      BootstrapPage.route: (_) => BootstrapPage(this, keyring),
      // earn pages
      // EarnPage.route: (_) => EarnPage(this, keyring),
      // EarnDetailPage.route: (_) => EarnDetailPage(this, keyring),
      // EarnHistoryPage.route: (_) => ClientProvider(
      //       child: Builder(
      //         builder: (_) => EarnHistoryPage(this, keyring),
      //       ),
      //       uri: GraphQLConfig['httpUri'],
      //     ),
      // EarnLiquidityDetailPage.route: (_) =>
      //     EarnLiquidityDetailPage(this, keyring),
      // EarnTxDetailPage.route: (_) => EarnTxDetailPage(this, keyring),
      // LPStakePage.route: (_) => LPStakePage(this, keyring),
      AddLiquidityPage.route: (_) => AddLiquidityPage(this, keyring),
      WithdrawLiquidityPage.route: (_) => WithdrawLiquidityPage(this, keyring),
      // NFT pages
      NFTPage.route: (_) => NFTPage(this, keyring),
      NFTDetailPage.route: (_) => NFTDetailPage(this, keyring),
      NFTTransferPage.route: (_) => NFTTransferPage(this, keyring),
      NFTBurnPage.route: (_) => NFTBurnPage(this, keyring),
      // Gov pages
      // DemocracyPage.route: (_) => DemocracyPage(this, keyring),
      // ReferendumVotePage.route: (_) => ReferendumVotePage(this, keyring),
      // ProposalDetailPage.route: (_) => ProposalDetailPage(this, keyring),
    };
  }

  @override
  Future<String> loadJSCode() => rootBundle.loadString(
      'packages/web3plugin_setheum/lib/js_service_setheum/dist/main.js');

  AcalaApi _api;
  AcalaApi get api => _api;

  StoreCache _cache;
  PluginStore _store;
  PluginService _service;
  PluginStore get store => _store;
  PluginService get service => _service;

  Future<void> _subscribeTokenBalances(KeyPairData acc) async {
    // todo: fix this after new acala online
    final enabled = basic.name == 'acala'
        ? _store.setting.liveModules['assets']['enabled']
        : true;

    _api.assets.subscribeTokenBalances(basic.name, acc.address, (data) {
      _store.assets.setTokenBalanceMap(data, acc.pubKey);

      balances.setTokens(data);
    }, transferEnabled: enabled);

    final nft = await _api.assets.queryNFTs(acc.address);
    if (nft != null) {
      _store.assets.setNFTs(nft);
    }
  }

  void _loadCacheData(KeyPairData acc) {
    balances.setExtraTokens([]);
    _store.assets.setNFTs([]);

    try {
      loadBalances(acc);

      _store.assets.loadCache(acc.pubKey);
      final tokens = _store.assets.tokenBalanceMap.values.toList();
      if (service.plugin.store.setting.tokensConfig['invisible'] != null) {
        final invisible =
            List.of(service.plugin.store.setting.tokensConfig['invisible']);
        if (invisible.length > 0) {
          tokens.removeWhere((token) => invisible.contains(token.id));
        }
      }
      balances.setTokens(tokens, isFromCache: true);

      _store.loan.loadCache(acc.pubKey);
      _store.swap.loadCache(acc.pubKey);
      print('acala plugin cache data loaded');
    } catch (err) {
      print(err);
      print('load acala cache data failed');
    }
  }

  @override
  Future<void> onWillStart(Keyring keyring) async {
    _api = AcalaApi(AcalaService(this));

    await GetStorage.init(plugin_cache_key);

    _cache = StoreCache();
    _store = PluginStore(_cache);
    _service = PluginService(this, keyring);

    _loadCacheData(keyring.current);

    _service.fetchLiveModules();

    // wait tokens config here for subscribe all tokens balances
    await _service.fetchTokensConfig();
  }

  @override
  Future<void> onStarted(Keyring keyring) async {
    _service.connected = true;

    if (keyring.current.address != null) {
      _subscribeTokenBalances(keyring.current);
    }
  }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _loadCacheData(acc);

    if (_service.connected) {
      _api.assets.unsubscribeTokenBalances(basic.name, acc.address);
      _subscribeTokenBalances(acc);
    }
  }

  List _randomList(List input) {
    final data = input.toList();
    final res = [];
    final _random = Random();
    for (var i = 0; i < input.length; i++) {
      final item = data[_random.nextInt(data.length)];
      res.add(item);
      data.remove(item);
    }
    return res;
  }
}
