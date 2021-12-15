import 'package:web3plugin_setheum/store/accounts.dart';
import 'package:web3plugin_setheum/store/assets.dart';
import 'package:web3plugin_setheum/store/cache/storeCache.dart';
import 'package:web3plugin_setheum/store/earn.dart';
import 'package:web3plugin_setheum/store/gov/governance.dart';
import 'package:web3plugin_setheum/store/homa.dart';
import 'package:web3plugin_setheum/store/loan.dart';
import 'package:web3plugin_setheum/store/setting.dart';
import 'package:web3plugin_setheum/store/swap.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : setting = SettingStore(cache),
        gov = GovernanceStore(cache),
        assets = AssetsStore(cache),
        loan = LoanStore(cache),
        earn = EarnStore(cache),
        swap = SwapStore(cache),
        homa = HomaStore(cache);

  final accounts = AccountsStore();

  final SettingStore setting;
  final AssetsStore assets;
  final LoanStore loan;
  final EarnStore earn;
  final HomaStore homa;
  final GovernanceStore gov;
  final SwapStore swap;
}
