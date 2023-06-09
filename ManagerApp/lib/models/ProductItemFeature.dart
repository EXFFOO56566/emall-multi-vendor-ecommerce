
class ProductItemFeature {

  int id;
  String feature,value;

  ProductItemFeature.empty();
  ProductItemFeature.fill(){
    this.feature = "Color";

  }

  ProductItemFeature(this.id, this.feature, this.value);

  static ProductItemFeature fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString()) ;
    String feature = (jsonObject['feature'].toString());
    String value  =jsonObject['value'].toString();

    return ProductItemFeature(id, feature, value);
  }

  static List<ProductItemFeature> getListFromJson(List<dynamic> jsonArray) {
    List<ProductItemFeature> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ProductItemFeature.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'ProductItemFeature{id: $id, feature: $feature, value: $value}';
  }

  bool isValid(){
    return feature!=null && feature.isNotEmpty && value!=null && value.isNotEmpty;
  }

  String toJSON(){
    return "{\"feature\":\""+feature.toString() + "\",\"value\":\""+value.toString() + "\"}";
  }

}
