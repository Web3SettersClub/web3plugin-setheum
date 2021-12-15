import 'package:web3plugin_setheum/common/constants/base.dart';

const plugin_cache_key = 'plugin_karura';

const plugin_genesis_hash =
    '0xbaf5aabe40646d11f0ee8abbdc64f4a4b7674925cba08e4a05ff9ebed6e2126b';
const acala_price_decimals = 18;
const karura_stable_coin = 'KUSD';
const karura_stable_coin_view = 'kUSD';

const relay_chain_name = 'kusama';
const para_chain_name_bifrost = 'bifrost';
const para_chain_ids = {
  para_chain_name_bifrost: 2001,
};

const network_ss58_format = {
  plugin_name_setheum: 8,
  relay_chain_name: 2,
  para_chain_name_bifrost: 6,
};
const relay_chain_token_symbol = 'KSM';
const para_chain_token_symbol_bifrost = 'BNC';
const cross_chain_xcm_fees = {
  relay_chain_name: {
    relay_chain_token_symbol: {
      'fee': '79999999',
      'existentialDeposit': '33333333',
    },
  },
  para_chain_name_bifrost: {
    relay_chain_token_symbol: {
      'fee': '64000000',
      'existentialDeposit': '100000000',
    },
    karura_stable_coin: {
      'fee': '25600000000',
      'existentialDeposit': '100000000',
    },
    para_chain_token_symbol_bifrost: {
      'fee': '5120000000',
      'existentialDeposit': '10000000000',
    },
    'VSKSM': {
      'fee': '64000000',
      'existentialDeposit': '100000000',
    }
  }
};
const xcm_dest_weight_kusama = '3000000000';
const xcm_dest_weight_karura = '600000000';
const xcm_dest_weight_v2 = '5000000000';

const existential_deposit = {
  'SETUSD': '100000000000000000',
  'SETR': '100000000000000000',
  'SERP': '100000000000000000',
  'DNAR': '100000000000000000',
  'SETM': '100000000000000000',
};

const acala_token_ids = [
  'SETM',
  'SERP',
  'DNAR',
  'SETR',
  'SETUSD',
];

const module_name_assets = 'assets';
const module_name_loan = 'loan';
const module_name_swap = 'swap';
const module_name_earn = 'earn';
const module_name_nft = 'nft';
const config_modules = {
  module_name_assets: {
    'visible': true,
    'enabled': false,
  },
  module_name_loan: {
    'visible': true,
    'enabled': false,
  },
  module_name_swap: {
    'visible': true,
    'enabled': false,
  },
  module_name_earn: {
    'visible': true,
    'enabled': false,
  },
  module_name_nft: {
    'visible': true,
    'enabled': true,
  },
};

const image_assets_uri = 'packages/web3plugin_setheum/assets/images';
const module_icons_uri = {
  module_name_loan: '$image_assets_uri/loan.svg',
  module_name_swap: '$image_assets_uri/swap.svg',
  module_name_earn: '$image_assets_uri/earn.svg',
  module_name_nft: '$image_assets_uri/nft.svg',
};

// todo: remove this, tx control config has been built in UI.TxConfirmPage.dart
const action_loan_adjust = 'honzon.adjustLoan';
const action_loan_close = 'honzon.closeLoanHasDebitByDex';
const action_swap_add_lp = 'dex.addLiquidity';
const action_swap_remove_lp = 'dex.removeLiquidity';
