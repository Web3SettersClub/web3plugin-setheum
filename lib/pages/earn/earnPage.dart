import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3plugin_setheum/pages/earn/earnDexList.dart';
import 'package:web3plugin_setheum/pages/earn/earnHistoryPage.dart';
import 'package:web3plugin_setheum/pages/earn/earnLoanList.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/storage/keyring.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/MainTabBar.dart';

class EarnPage extends StatefulWidget {
  EarnPage(this.plugin, this.keyring);
  final PluginSetheum plugin;
  final Keyring keyring;

  static const String route = '/karura/earn';

  @override
  _EarnPageState createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['earn.title']),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).cardColor),
            onPressed: () =>
                Navigator.of(context).pushNamed(EarnHistoryPage.route),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: MainTabBar(
                fontSize: 20,
                lineWidth: 6,
                tabs: [dic['earn.dex'], dic['earn.loan']],
                activeTab: _tab,
                onTap: (i) {
                  setState(() {
                    _tab = i;
                  });
                },
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? EarnDexList(widget.plugin)
                  : EarnLoanList(widget.plugin, widget.keyring),
            )
          ],
        ),
      ),
    );
  }
}
