import 'package:web3plugin_setheum/api/acalaService.dart';
import 'package:web3plugin_setheum/api/assets/acalaApiAssets.dart';
import 'package:web3plugin_setheum/api/earn/acalaApiEarn.dart';
import 'package:web3plugin_setheum/api/homa/acalaApiHoma.dart';
import 'package:web3plugin_setheum/api/loan/acalaApiLoan.dart';
import 'package:web3plugin_setheum/api/swap/acalaApiSwap.dart';

class AcalaApi {
  AcalaApi(AcalaService service)
      : assets = AcalaApiAssets(service.assets),
        loan = AcalaApiLoan(service.loan),
        swap = AcalaApiSwap(service.swap),
        homa = AcalaApiHoma(service.homa),
        earn = AcalaApiEarn(service.earn);

  final AcalaApiAssets assets;
  final AcalaApiLoan loan;
  final AcalaApiSwap swap;
  final AcalaApiHoma homa;
  final AcalaApiEarn earn;
}
