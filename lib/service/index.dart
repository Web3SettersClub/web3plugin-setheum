import 'package:flutter/cupertino.dart';
import 'package:web3plugin_setheum/common/constants/base.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/service/serviceAssets.dart';
import 'package:web3plugin_setheum/service/serviceEarn.dart';
import 'package:web3plugin_setheum/service/serviceGov.dart';
import 'package:web3plugin_setheum/service/serviceHoma.dart';
import 'package:web3plugin_setheum/service/serviceLoan.dart';
import 'package:web3plugin_setheum/service/walletApi.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/storage/types/keyPairData.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/passwordInputDialog.dart';
import 'package:web3wallet_ui/utils/i18n.dart';

class PluginService {
  PluginService(PluginSetheum plugin, Keyring keyring)
      : assets = ServiceAssets(plugin, keyring),
        loan = ServiceLoan(plugin, keyring),
        earn = ServiceEarn(plugin, keyring),
        homa = ServiceHoma(plugin, keyring),
        gov = ServiceGov(plugin, keyring),
        plugin = plugin;
  final ServiceAssets assets;
  final ServiceLoan loan;
  final ServiceEarn earn;
  final ServiceHoma homa;
  final ServiceGov gov;

  final PluginSetheum plugin;

  bool connected = false;

  Future<String> getPassword(BuildContext context, KeyPairData acc) async {
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          plugin.sdk.api,
          title: Text(
              I18n.of(context).getDic(i18n_full_dic_ui, 'common')['unlock']),
          account: acc,
        );
      },
    );
    return password;
  }

  Future<void> fetchLiveModules() async {
    final res = plugin.basic.name == plugin_name_setheum
        ? await WalletApi.getLiveModules()
        : config_modules;
    if (res != null) {
      plugin.store.setting.setLiveModules(res);
    } else {
      plugin.store.setting.setLiveModules(config_modules);
    }
  }

  Future<void> fetchTokensConfig() async {
    final res = await WalletApi.getTokensConfig();
    if (res != null) {
      plugin.store.setting.setTokensConfig(res);
    }
  }
}
