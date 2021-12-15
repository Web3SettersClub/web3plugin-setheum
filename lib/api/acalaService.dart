import 'package:web3plugin_setheum/api/assets/acalaServiceAssets.dart';
import 'package:web3plugin_setheum/api/earn/acalaServiceEarn.dart';
import 'package:web3plugin_setheum/api/homa/acalaServiceHoma.dart';
import 'package:web3plugin_setheum/api/loan/acalaServiceLoan.dart';
import 'package:web3plugin_setheum/api/swap/acalaServiceSwap.dart';
import 'package:web3plugin_setheum/web3plugin_setheum.dart';

class AcalaService {
  AcalaService(PluginSetheum plugin)
      : assets = AcalaServiceAssets(plugin),
        loan = AcalaServiceLoan(plugin),
        swap = AcalaServiceSwap(plugin),
        homa = AcalaServiceHoma(plugin),
        earn = AcalaServiceEarn(plugin);

  final AcalaServiceAssets assets;
  final AcalaServiceLoan loan;
  final AcalaServiceSwap swap;
  final AcalaServiceHoma homa;
  final AcalaServiceEarn earn;
}
