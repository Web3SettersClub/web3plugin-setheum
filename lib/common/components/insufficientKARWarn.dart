import 'package:flutter/material.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';
import 'package:web3wallet_ui/components/textTag.dart';

class InsufficientKARWarn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'acala');
    return Row(
      children: [
        Expanded(
          child: TextTag(
            dic['warn.fee'],
            padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
            margin: EdgeInsets.only(bottom: 8),
            color: Colors.deepOrangeAccent,
          ),
        )
      ],
    );
  }
}
