import 'dart:convert';
import 'dart:math';

import 'package:web3plugin_setheum/common/constants/index.dart';
import 'package:web3wallet_ui/utils/format.dart';

class TxLoanData extends _TxLoanData {
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';
  static const String actionTypeBorrow = 'mint';
  static const String actionTypePayback = 'payback';
  static const String actionTypeCreate = 'create';
  static const String actionLiquidate = 'liquidate';
  static TxLoanData fromJson(Map json, String stableCoinSymbol,
      int stableCoinDecimals, int tokenDecimals) {
    TxLoanData data = TxLoanData();
    data.event = json['type'];
    data.hash = json['extrinsic']['id'];

    final jsonData = json['data'] as List;
    data.token = jsonDecode(jsonData[1]['value'])['token'];

    data.collateral = Fmt.balanceInt(jsonData[2]['value'].toString());
    data.debit = jsonData.length > 4
        ? Fmt.balanceInt(jsonData[3]['value'].toString()) *
            Fmt.balanceInt(
                (jsonData[4]['value'] ?? '1000000000000').toString()) ~/
            BigInt.from(pow(10, acala_price_decimals))
        : BigInt.zero;
    data.amountCollateral =
        Fmt.priceFloorBigInt(BigInt.zero - data.collateral, tokenDecimals);
    data.amountDebit = Fmt.priceCeilBigInt(data.debit, stableCoinDecimals);
    if (data.event == 'ConfiscateCollateralAndDebit') {
      data.actionType = actionLiquidate;
    } else if (data.collateral == BigInt.zero) {
      data.actionType =
          data.debit > BigInt.zero ? actionTypeBorrow : actionTypePayback;
    } else if (data.debit == BigInt.zero) {
      data.actionType = data.collateral > BigInt.zero
          ? actionTypeDeposit
          : actionTypeWithdraw;
    } else if (data.debit < BigInt.zero) {
      data.actionType = actionTypePayback;
    } else {
      data.actionType = actionTypeCreate;
    }

    data.time = (json['extrinsic']['timestamp'] as String).replaceAll(' ', '');
    data.isSuccess = json['extrinsic']['isSuccess'];
    return data;
  }
}

abstract class _TxLoanData {
  String block;
  String hash;

  String token;
  String event;
  String actionType;
  BigInt collateral;
  BigInt debit;
  String amountCollateral;
  String amountDebit;

  String time;
  bool isSuccess = true;
}
