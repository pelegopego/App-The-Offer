class Favorito {
  int productId;
  int id;
  String name;
  String image;
  String price;
  String currencySymbol;
  String slug;
  Favorito(
      {this.currencySymbol,
      this.image,
      this.price,
      this.name,
      this.slug,
      this.id,
      this.productId});
}
