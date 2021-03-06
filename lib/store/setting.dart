import 'package:mobx/mobx.dart';
import 'package:web3plugin_setheum/store/cache/storeCache.dart';

part 'setting.g.dart';

class SettingStore extends _SettingStore with _$SettingStore {
  SettingStore(StoreCache cache) : super(cache);
}

abstract class _SettingStore with Store {
  _SettingStore(this.cache);

  final StoreCache cache;

  @observable
  Map liveModules = Map();

  Map tokensConfig = Map();

  @action
  void setLiveModules(Map value) {
    liveModules = value;
  }

  void setTokensConfig(Map config) {
    tokensConfig = config;
  }
}
