import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:web3plugin_setheum/pages/gov/democracy/proposalDetailPage.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/api/types/gov/proposalInfoData.dart';
import 'package:web3wallet_sdk/api/types/gov/treasuryOverviewData.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/addressIcon.dart';
import 'package:web3wallet_ui/components/roundedCard.dart';
import 'package:web3wallet_ui/utils/format.dart';
import 'package:web3wallet_ui/utils/index.dart';

class ProposalPanel extends StatelessWidget {
  ProposalPanel(this.plugin, this.proposal);

  final PluginSetheum plugin;
  final ProposalInfoData proposal;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'gov');
          final decimals = plugin.networkState.tokenDecimals[0];
          final symbol = plugin.networkState.tokenSymbol[0] ?? '';
          final CouncilProposalData proposalMeta = proposal.image?.proposal;
          final Map accInfo =
              plugin.store.accounts.addressIndexMap[proposal.proposer];
          final proposerIcon =
              plugin.store.accounts.addressIconsMap[proposal.proposer];
          final List seconding = proposal.seconds.toList();
          seconding.removeAt(0);
          return GestureDetector(
            child: RoundedCard(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        proposalMeta != null
                            ? '${proposalMeta.section}.${proposalMeta.method}'
                            : 'preimage: ${Fmt.address(proposal.imageHash)}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(
                        '#${BigInt.parse(proposal.index)}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: <Widget>[
                      AddressIcon(proposal.proposer, svg: proposerIcon),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              UI.accountDisplayName(proposal.proposer, accInfo),
                              Text(
                                '${dic['treasury.bond']}: ${Fmt.balance(
                                  proposal.balance.toString(),
                                  decimals,
                                )} $symbol',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            seconding.length.toString(),
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(dic['proposal.seconds'])
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.of(context)
                .pushNamed(ProposalDetailPage.route, arguments: proposal),
          );
        },
      );
}
