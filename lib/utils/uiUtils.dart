import 'package:flutter/cupertino.dart';
import 'package:web3plugin_setheum/utils/i18n/index.dart';
import 'package:web3wallet_sdk/utils/i18n.dart';

class UIUtils {
  static void showInvalidActionAlert(BuildContext context, String action) {
    final dic = I18n.of(context).getDic(i18n_full_dic_karura, 'common');
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(action),
            content: Text(dic['action.disable']),
            actions: [
              CupertinoButton(
                child: Text(dic['cancel']),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
