import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3plugin_setheum/pages/earn/earnPage.dart';
import 'package:web3plugin_setheum/pages/gov/democracyPage.dart';
import 'package:web3plugin_setheum/pages/homa/homaPage.dart';
import 'package:web3plugin_setheum/pages/loan/loanPage.dart';
import 'package:web3plugin_setheum/pages/nft/nftPage.dart';
import 'package:web3plugin_setheum/pages/swap/swapPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/entryPageCard.dart';

class AcalaEntry extends StatefulWidget {
  AcalaEntry(this.plugin, this.keyring);

  final PluginSetheum plugin;
  final Keyring keyring;

  @override
  _AcalaEntryState createState() => _AcalaEntryState();
}

class _AcalaEntryState extends State<AcalaEntry> {
  final _liveModuleRoutes = {
    'loan': LoanPage.route,
    'swap': SwapPage.route,
    'nft': NFTPage.route,
    // 'gov': NFTPage.route,  // Replace with treasury and add staking
  };

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'common');
    final dicGov = I18n.of(context).getDic(i18n_full_dic_karura, 'gov');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dic['karura'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (widget.plugin.sdk.api?.connectedNode == null) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 2),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(),
                          Text(dic['node.connecting']),
                        ],
                      ),
                    );
                  }
                  final modulesConfig = widget.plugin.store.setting.liveModules;
                  final List liveModules =
                      modulesConfig.keys.toList().sublist(1);

                  liveModules?.retainWhere((e) => modulesConfig[e]['visible']);

                  return ListView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: <Widget>[
                      Container(
                        height: 68,
                        margin: EdgeInsets.only(bottom: 16),
                        child: SvgPicture.asset(
                            'packages/web3plugin_setheum/assets/images/logo_kar_empty.svg',
                            color: Colors.white70),
                      ),
                      ...liveModules.map((e) {
                        final enabled = modulesConfig[e]['enabled'];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            child: EntryPageCard(
                              dic['$e.title'],
                              enabled ? dic['$e.brief'] : dic['coming'],
                              SvgPicture.asset(
                                module_icons_uri[e],
                                height: 88,
                              ),
                              color: Colors.transparent,
                            ),
                            onTap: () => Navigator.of(context).pushNamed(
                                _liveModuleRoutes[e],
                                arguments: enabled),
                          ),
                        );
                      }).toList(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dicGov['democracy'],
                            dicGov['democracy.brief'],
                            SvgPicture.asset(
                              'packages/web3plugin_setheum/assets/images/democracy.svg',
                              height: 88,
                              color: Theme.of(context).primaryColor,
                            ),
                            color: Colors.transparent,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(DemocracyPage.route),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
