class IncentivesData extends _IncentivesData {
  static IncentivesData fromJson(Map json) {
    final res = new IncentivesData();
    res.dex = Map.from(json['Dex']).map((k, v) => MapEntry(
        k, List.of(v).map((e) => IncentiveItemData.fromJson(e)).toList()));
    res.dexSaving = Map.from(json['DexSaving']).map((k, v) => MapEntry(
        k, List.of(v).map((e) => IncentiveItemData.fromJson(e)).toList()));
    res.loans = Map.from(json['Loans']).map((k, v) => MapEntry(
        k, List.of(v).map((e) => IncentiveItemData.fromJson(e)).toList()));
    return res;
  }
}

abstract class _IncentivesData {
  Map<String, List<IncentiveItemData>> dex;
  Map<String, List<IncentiveItemData>> dexSaving;
  Map<String, List<IncentiveItemData>> loans;
}

class IncentiveItemData extends _IncentiveItemData {
  static IncentiveItemData fromJson(Map json) {
    final res = new IncentiveItemData();
    res.token = json['token'];
    res.amount = double.parse(json['amount']);
    res.deduction = double.parse(json['deduction']);
    return res;
  }
}

abstract class _IncentiveItemData {
  String token;
  double amount;
  double deduction;
  double apr;
}
